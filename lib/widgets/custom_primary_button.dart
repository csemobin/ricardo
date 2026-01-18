import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onHandler;

  const CustomPrimaryButton({
    super.key,
    required this.title,
    required this.onHandler,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onHandler != null;

    return GestureDetector(
      onTap: isEnabled ? onHandler : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        alignment: Alignment.center,
        width: double.maxFinite,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? [
              Color(0Xff1BB600),
              Color(0Xff007635),
              Color(0Xff01AF44),
            ]
                : [
              Color(0Xff1BB600).withOpacity(0.5),
              Color(0Xff007635).withOpacity(0.5),
              Color(0Xff01AF44).withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: isEnabled ? Colors.green : Colors.green.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}