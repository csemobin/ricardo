import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ricardo/app.dart';
import 'package:ricardo/app/helpers/device_utils.dart';
import 'package:ricardo/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DeviceUtils.lockDevicePortrait();
  runApp(RideSharingApplication());
}