import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';

class CustomImageUploader extends StatelessWidget {
  final String? label, uploadedTitle, fileSize, buttonTitle;

  const CustomImageUploader(
      {super.key,
      this.label,
      this.uploadedTitle,
      this.fileSize,
      this.buttonTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textAlign: TextAlign.start,
          '$label',
          style: TextStyle(
            color: AppColors.labelTextColor,
            fontSize: 12.h,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(15),
          dashPattern: [8, 10],
          color: AppColors.dottedBorderColor,
          strokeWidth: 1,
          child: Container(
            height: 110.h,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.images.uploadIcon.path,
                    height: 24,
                    width: 24,
                  ),
                  Text(
                    '$uploadedTitle',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.dottedBorderColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Max file size: $fileSize MB',
                    style: TextStyle(
                        fontSize: 10.h,
                        color: AppColors.secondaryTextColor,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 4.h,),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.r,
                      horizontal: 30.r,
                    ),
                    decoration: BoxDecoration(
                        color: AppColors.greenColor,
                        borderRadius: BorderRadius.circular(30.r)),
                    child: Text(
                      '$buttonTitle',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
