import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({
    super.key,
    required this.mapOPTController,
  });

  final MapOPTController mapOPTController;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      bottom: 650,
      child: Obx(() {
        final userController = Get.find<UserController>();

        final user = userController.userModel.value?.userProfile;
        final profileImage =
            user?.image?.filename ?? Assets.images.profileImage.path;
        final userName = user?.name ?? 'User';
        // ✅ In your initState or wherever you load user data

        return ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Color(0x80FFFFFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  '${ApiUrls.imageBaseUrl}$profileImage',
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      Assets.images.profileImage.path,
                                      fit: BoxFit.cover,
                                      width: 50,
                                      height: 50,
                                    );
                                  },
                                ),
                                /*child: GestureDetector(
                                  onTap: () {
                                    final cnt = Get.find<
                                        CustomBottomNavBarController>();
                                    cnt.selectedIndex.value = 3;
                                    Get.toNamed(AppRoutes.customBottomNavBar);
                                  },
                                  child: Image.network(
                                    '${ApiUrls.imageBaseUrl}$profileImage',
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        Assets.images.profileImage.path,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      );
                                    },
                                  ),
                                ),*/
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.notificationScreen),
                              child: Image.asset(
                                Assets.images.bell.path,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Image.asset(
                              Assets.images.greenPin.path,
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                mapOPTController.currentLocation.value,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Image.asset(Assets.images.rightArrow.path),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}