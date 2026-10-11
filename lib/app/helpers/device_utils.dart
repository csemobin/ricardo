import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceUtils {
  static statusBarColor() {
    // Edge-to-edge tells Android to let app content draw under the status &
    // navigation bars, instead of reserving (black) space for them. Without
    // this, the map is letterboxed by the status bar on first launch and
    // only goes full-screen after a re-layout (e.g., tab switch).
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }
  static systemNavigationBarColor(){
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }
  static lockDevicePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}