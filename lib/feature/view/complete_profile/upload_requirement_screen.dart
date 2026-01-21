import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';

class UploadRequirementScreen extends StatelessWidget {
  UploadRequirementScreen({super.key});

  final controller = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          Center(
            child: CustomHeadingText(
              firstText: 'Upload Required ',
              secondText: 'Documents',
              isColumn: true,
              isSwipedColor: true,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Center(
            child: CustomSecondaryText(
                text:
                    'Please upload the required documents to complete your application proccess'),
          ),
          SizedBox(
            height: 65.h,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GetBuilder<UserController>(builder: (_) {
                  final userProfile = controller.userModel?.driverProfile;
                  return GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: AppColors.whiteColor,
                        // border: Border.all(
                        //   color: AppColors.primaryColor,
                        //   width: 2,
                        // ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(Assets.images.documentIcon.path),
                              SizedBox(
                                width: 14.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Driving License',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    userProfile!.licenseUploaded == true
                                        ? 'Uploaded'
                                        : 'Not Uploaded',
                                    style: TextStyle(
                                      color: userProfile.licenseUploaded == true
                                          ? AppColors.greenColor
                                          : AppColors.errorColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.darkColor,
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Get.toNamed(AppRoutes.uploadDrivingLicenseScreen),
                  );
                }),
                SizedBox(
                  height: 25.h,
                ),
                GetBuilder<UserController>(builder: (_) {
                  final vehicleData = controller.userModel?.driverProfile;
                  return GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.whiteColor,
                          border: Border.all(
                              color: Color(0Xff0F0F0D).withAlpha(9), width: 2)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(Assets.images.carIcon.path),
                              SizedBox(
                                width: 14.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Car Registration',
                                    style: TextStyle(
                                      color: AppColors.greenColor,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    vehicleData!.vehicleDataUploaded == true
                                        ? 'Uploaded'
                                        : 'Not Uploaded',
                                    style: TextStyle(
                                      color:
                                      vehicleData.vehicleDataUploaded == true
                                          ? AppColors.greenColor
                                          : AppColors.errorColor,
                                      fontSize: 12.sp,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.darkColor,
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Get.toNamed(AppRoutes.carRegistrationScreen),
                  );
                }),
                Spacer(),
                Spacer(),
                Spacer(),
                CustomPrimaryButton(
                  title: 'Submit',
                  onHandler: () {
                    // Get.toNamed(AppRoutes.uploadDrivingLicenseScreen);
                  },
                ),
                Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
