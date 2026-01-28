import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/profile/support_controller.dart';
import 'package:ricardo/feature/simmer/edit_profile_simmer.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class EditProfileSupportScreen extends GetView<SupportController> {
  EditProfileSupportScreen({super.key});

  @override
  final controller = Get.put(SupportController());

  @override
  Widget build(BuildContext context) {
    controller.fetchSupportData();

    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          'Support',
          style: TextStyle(
            color: AppColors.primaryHeadingTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: LayoutBuilder(builder: (context, containers) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: containers.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(children: [
                SizedBox(height: 73.h),
                Image.asset(Assets.images.supportCarImage.path),
                SizedBox(height: 68.h),

                // Email Section
                Obx(() {
                  if (controller.isLoading.value) {
                    return ShimmerContainer();
                  }
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 58.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: AppColors.whiteColor),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(Assets.images.supportEmailImage.path),
                            SizedBox(width: 16.w),
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackButton,
                                fontFamily: FontFamily.poppins,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          controller.supportModel.value?.value?.email ?? 'No email',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                            fontFamily: FontFamily.poppins,
                          ),
                        )
                      ],
                    ),
                  );
                }),

                SizedBox(height: 24.h),

                // Phone Section
                Obx(() {
                  if (controller.isLoading.value) {
                    return ShimmerContainer();
                  }
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 58.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: AppColors.whiteColor),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.whiteColor.withOpacity(0.09),
                          blurRadius: 0,
                          offset: Offset(0, -4),
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(Assets.images.supportPhoneImage.path),
                            SizedBox(width: 16.w),
                            Text(
                              'Phone',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackButton,
                                fontFamily: FontFamily.poppins,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          controller.supportModel.value?.value?.phone ?? 'No Number',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                            fontFamily: FontFamily.poppins,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ]),
            ),
          ),
        );
      }),
    );
  }
}