import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String title;

  @override
  const CustomPrimaryButton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0Xff1BB600),
              Color(0Xff007635),
              Color(0Xff01AF44),
            ],
          ),
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: Colors.green,
            width: 1,
          )
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      onTap: () {},
    );
  }
}
