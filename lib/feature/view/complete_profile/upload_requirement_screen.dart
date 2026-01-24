import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/view/complete_profile/profile_complete_popup_model_screen.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';

class UploadRequirementScreen extends StatefulWidget {
  const UploadRequirementScreen({super.key});

  @override
  State<UploadRequirementScreen> createState() => _UploadRequirementScreenState();
}

class _UploadRequirementScreenState extends State<UploadRequirementScreen> {
  final controller = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    controller.fetchUser();
  }

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
                'Please upload the required documents to complete your application process'),
          ),
          SizedBox(
            height: 65.h,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Driving License Card
                GetBuilder<UserController>(
                  builder: (controller) {
                    final driverProfile = controller.userModel?.value?.driverProfile;
                    final isLicenseUploaded = driverProfile?.licenseUploaded ?? false;

                    return _buildDocumentCard(
                      icon: Assets.images.documentIcon.path,
                      title: 'Driving License',
                      titleColor: AppColors.primaryColor,
                      isUploaded: isLicenseUploaded,
                      onTap: () async {
                        await Get.toNamed(AppRoutes.uploadDrivingLicenseScreen);
                        controller.fetchUser();
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 25.h,
                ),
                // Car Registration Card
                GetBuilder<UserController>(
                  builder: (controller) {
                    final driverProfile = controller.userModel?.value?.driverProfile;
                    final isVehicleUploaded = driverProfile?.vehicleDataUploaded ?? false;

                    return _buildDocumentCard(
                      icon: Assets.images.carIcon.path,
                      title: 'Car Registration',
                      titleColor: AppColors.greenColor,
                      isUploaded: isVehicleUploaded,
                      onTap: () async {
                        await Get.toNamed(AppRoutes.carRegistrationScreen);
                        // Refresh data when returning from upload screen
                        controller.fetchUser();
                      },
                      hasBorder: true,
                    );
                  },
                ),
                Spacer(),
                Spacer(),
                Spacer(),
                GetBuilder<UserController>(
                    builder: (controller){
                      final driverProfile = controller.userModel?.value?.driverProfile;
                      final isVehicleUploaded = driverProfile?.vehicleDataUploaded ?? false;
                      final isLicenceUploaded = driverProfile?.licenseUploaded ?? false;
                      return CustomPrimaryButton(
                        title: 'Submit',
                        onHandler: isLicenceUploaded && isVehicleUploaded == true ? (){
                          Get.offAllNamed(AppRoutes.profileCompletePopupModelScreen);
                        } : null,
                      );
                    }
                ),
                Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String icon,
    required String title,
    required Color titleColor,
    required bool isUploaded,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.whiteColor,
          border: hasBorder
              ? Border.all(
            color: Color(0Xff0F0F0D).withAlpha(9),
            width: 2,
          )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(icon),
                SizedBox(
                  width: 14.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isUploaded ? 'Uploaded' : 'Not Uploaded',
                      style: TextStyle(
                        color: isUploaded
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
    );
  }
}