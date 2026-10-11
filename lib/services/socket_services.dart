import 'dart:async';
import 'package:ricardo/app/helpers/device_helper.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';



class SocketServices {
  static String token = '';
  static IO.Socket? socket;
  static void Function()? onReconnected;

  // Singleton pattern
  static final SocketServices _instance = SocketServices._internal();
  factory SocketServices() => _instance;
  SocketServices._internal();

  static Future<void> init() async {
    // Fetch the token from preferences
    token = await PrefsHelper.getString(AppConstants.bearerToken);

    // Check if the token is available
    if (token.isEmpty) {
      print("Token is missing! Cannot initialize the socket connection.");
      return; // Return early if token is missing
    }

    print("Initializing socket with token: $token  \n time${DateTime.now()}");

    // Disconnect the existing socket if connected
    if (socket?.connected ?? false) {
      socket?.disconnect();
      socket = null;
    }

    // Setup the socket connection with the token in the headers
    socket = IO.io(
      ApiUrls.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({"token": token})
          .enableReconnection()
          .enableForceNew()
          .build(),
    );
    print("Socket initialized with token: $token  \n time${DateTime.now()}");

    // Setup event listeners
    // Re-emit user-connected on every (re)connect so the server can route
    // ride-request / ride-status events to this socket. This covers:
    //   - cold-start while offline → first connect when network returns
    //   - mid-session network drop and reconnect
    socket?.onConnect((_) async {
      print('✅ Socket connected — emitting user-connected');
      final t = await PrefsHelper.getString(AppConstants.bearerToken);
      final fcm = await PrefsHelper.getString(AppConstants.fcmToken);
      final deviceId = await DeviceHelper.getDeviceId();

      if (t.isNotEmpty && fcm.isNotEmpty) {
        socket?.emit('user-connected', {
          "accessToken": t,
          "fcmToken": fcm,
          "deviceId": deviceId,
        });
      }
      onReconnected?.call();
    });
    socket?.onConnectError((err) => print('❌ Socket connection error: $err'));
    socket?.onError((err) => print('❌ Socket error: $err'));
    socket?.onDisconnect(
            (reason) => print('⚠️ Socket disconnected. Reason: $reason'));

    // Connect the socket after the token is set
    socket?.connect();
  }

  // Instance method for listening to events
  void on(String event, Function(dynamic) handler) {
    socket?.on(event, handler);
    print('📡 Listening to socket event: $event');
  }

  // Instance method for removing event listeners
  void off(String event) {
    socket?.off(event);
    print('🔇 Stopped listening to socket event: $event');
  }

  // Static method for emitting with acknowledgment
  static Future<dynamic> emitWithAck(String event, dynamic body) async {
    Completer<dynamic> completer = Completer<dynamic>();
    socket?.emitWithAck(event, body, ack: (data) {
      if (data != null) {
        completer.complete(data);
      } else {
        completer.complete(1);
      }
    });
    return completer.future;
  }

  // Static method for emitting events
  static emit(String event, dynamic body) {
    if (body != null) {
      socket?.emit(event, body);
      print('===========> Emit $event and \n $body');
    }
  }

  // Check if socket is connected
  static bool get isConnected => socket?.connected ?? false;

  // Disconnect socket
  static void disconnect() {
    socket?.disconnect();
    print('🔌 Socket disconnected');
  }
}