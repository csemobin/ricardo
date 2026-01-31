import 'package:flutter/material.dart';
import 'package:ricardo/app.dart';
import 'package:ricardo/app/helpers/device_utils.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  DeviceUtils.lockDevicePortrait();
  runApp(RideSharingApplication());
}