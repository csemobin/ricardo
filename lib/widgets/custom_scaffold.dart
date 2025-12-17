import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class CustomScaffold extends StatelessWidget {
  const CustomScaffold(
      {super.key,
      this.appBar,
      this.body,
      this.floatingActionButton,
      this.bottomNavigationBar,
      this.paddingSide, this.resizeToAvoidBottomInset});

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final double? paddingSide;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0XffF5F6FA),
      appBar: appBar,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.only(left: paddingSide ?? 25.w,right: paddingSide ?? 25.w),
        child: body,
      )),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset
    );
  }
}
