import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onHandler;
  final bool isLoading;

  const CustomPrimaryButton({
    super.key,
    required this.title,
    required this.onHandler,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onHandler != null && !isLoading;

    return GestureDetector(
      onTap: isEnabled ? onHandler : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        width: double.maxFinite,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? const [
                    Color(0Xff1BB600),
                    Color(0Xff007635),
                    Color(0Xff01AF44),
                  ]
                : [
                    const Color(0Xff1BB600).withValues(alpha: 0.45),
                    const Color(0Xff007635).withValues(alpha: 0.45),
                    const Color(0Xff01AF44).withValues(alpha: 0.45),
                  ],
          ),
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: isEnabled
                ? Colors.green
                : Colors.green.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: Colors.white,
                ),
              )
            : Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isEnabled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.75),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }
}
