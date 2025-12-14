import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ToastMessageHelper{
  static void showToastMessage(String message, {int? secound,Color? actionColor}) {

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: secound ?? 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.h,
    );

  }
}