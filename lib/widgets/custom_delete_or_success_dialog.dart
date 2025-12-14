import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showDeleteORSuccessDialog(BuildContext context,
    {required VoidCallback onTap,
    bool isSuccess = false,
      String? title,
    String? message,
    String? buttonLabel,
      Color? buttonColor,

    }) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            if (isSuccess)
               Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 60.r),
            if (!isSuccess)
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8.w),
            Flexible(child: Text(title?? 'Delete Item')),
          ],
        ),
        content: Text(
          message ??
              "Are you sure you want to delete this item? This action cannot be undone.",
          style: TextStyle(fontSize: 16.sp),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor ?? Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: onTap,
            child: Text(buttonLabel ?? "Delete"),
          ),
        ],
      );
    },
  );
}
