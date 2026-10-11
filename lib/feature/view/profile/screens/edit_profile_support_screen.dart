import 'package:flutter/material.dart';
import 'package:ricardo/feature/controllers/profile/support_controller.dart';
import 'package:ricardo/feature/simmer/edit_profile_simmer.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/logo_widget.dart';

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
                Center(
                  child: LogoWidget(
                    width: 80.w,
                    height: 80.h,
                  ),
                ),
                SizedBox(height: 73.h),
                Image.asset(Assets.images.supportCarImage.path),
                SizedBox(height: 68.h),

                // Email Section
                Obx(() {
                  if (controller.isLoading.value) {
                    return ShimmerContainer();
                  }
                  return GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse("mailto:${controller.supportModel.value?.value?.email}"));
                    },
                    child: Container(
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
                              Image.asset(Assets.images.supportEmailImage.path,),
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
                    ),
                  );
                }),

                SizedBox(height: 24.h),

                // Phone Section
                Obx(() {
                  if (controller.isLoading.value) {
                    return ShimmerContainer();
                  }
                  return GestureDetector(
                    onTap: (){
                      launchUrl(Uri.parse("tel:${controller.supportModel.value?.value?.phone}"));
                    },
                    child: Container(
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
                      child: RepaintBoundary(
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
                      ),
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