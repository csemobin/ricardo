import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/app.dart';
import 'package:ricardo/app/helpers/device_utils.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart';
import 'package:ricardo/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ricardo/services/get_fcm_tocken.dart';
import 'package:ricardo/services/socket_services.dart';

import 'app/helpers/prefs_helper.dart';
import 'app/utils/app_constants.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DeviceUtils.lockDevicePortrait();
  await FirebaseNotificationService.printFCMToken();
  await FirebaseNotificationService.initialize();
  // await SocketServices.init();
  // await Get.putAsync(() => SocketServices.init(),permanent: true);
  await SocketServices.init();
  final String token =
      await PrefsHelper.getString(AppConstants.bearerToken);
  final String fcmToken = await PrefsHelper.getString(AppConstants.fcmToken);
  if (token.isNotEmpty) {
    SocketServices.socket
        ?.emit('user-connected', {"accessToken": token, "fcmToken": fcmToken});
  }

  runApp(RideSharingApplication());
}
