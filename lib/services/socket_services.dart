import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/services/api_urls.dart';







class SocketServices {
  static String token = '';
  static IO.Socket? socket;


  static Future<void> init() async {
    // Fetch the token from preferences
    token = await PrefsHelper.getString(AppConstants.bearerToken);

    // Check if the token is available
    if (token.isEmpty) {
      print("Token is missing! Cannot initialize the socket connection.");
      return;  // Return early if token is missing
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
    socket?.onConnect((_) => print('✅ Socket connected successfully'));
    socket?.onConnectError((err) => print('❌ Socket connection error: $err'));
    socket?.onError((err) => print('❌ Socket error: $err'));
    socket?.onDisconnect((reason) => print('⚠️ Socket disconnected. Reason: $reason'));

    // Connect the socket after the token is set
    socket?.connect();
  }

  void on(String event, Function(dynamic) handler) {
    socket?.on(event, handler);
  }

  void off(String event, Function(dynamic) handler) {
    socket?.off(event, handler);
  }

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

  /// Emit without acknowledgment
  void emit(String event, dynamic body) {
    if (socket != null && socket!.connected) {
      socket!.emit(event, body);
      print('📤 Emit: $event\n➡️ Data: $body');
    } else {
      print("⚠️ Emit failed: socket not connected");
    }
  }

  /// Disconnect socket
  void disconnect() {

    socket?.disconnect();
    print('🔌 Socket manually disconnected');
  }
}


