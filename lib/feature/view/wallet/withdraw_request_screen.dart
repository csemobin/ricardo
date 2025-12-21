import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class WithdrawRequestScreen extends StatelessWidget {
  WithdrawRequestScreen({super.key});

  final TextEditingController emailTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: AppBar(
          backgroundColor: AppColors.bgColor,
          forceMaterialTransparency: true,
          centerTitle: true,
          title: Text('Withdraw Request'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: emailTEController,
                hintText: 'Enter Amount',
                labelText: 'Enter Amount',
              ),
              SizedBox(
                height: 18.h,
              ),
              // Select Card Section work are here
              Text(
                'Select Card',
                style: AppCustomDesign.walletScreenTextStyle,
              ),
              SizedBox(
                height: 15.h,
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 18.r, horizontal: 12.r),
                          decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(4.r)),
                          child: Row(
                            children: [
                              Image.asset(Assets.images.visa.path),
                              SizedBox(
                                width: 13.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '**** **** **** 8970',
                                    style: testStyle(
                                      color: AppColors.cardTitle,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Bank: Meghna LTD.',
                                    style: TextStyle(
                                      color: AppColors.cardSubTitle,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 8.h,
                  );
                },
              ),
              SizedBox(height: 25.h),
              // Button Related Work are here
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.addCardScreen);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.blackButton,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(Assets.images.paymentMethodIcon.path),
                      SizedBox(
                        width: 20.w,
                      ),
                      Text(
                        'Add Payment Info',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 14.h,
              ),
              CustomPrimaryButton(
                  title: 'Withdraw',
                  onHandler: () => confirmRequestPopupModal(context)),
              SizedBox(
                height: 40.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 18.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: Color(0x0D01AF44)),
                child: Text(
                  'Our payment cycle runs every Friday. If you need your payment earlier, our support team is here to help—just reach out!',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Color(0xff787878),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ));
  }

  void confirmRequestPopupModal(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 15,
                  sigmaY: 15,
                ),
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                      color: AppColors.whiteColor.withOpacity(0.30),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.30))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Image.asset(Assets.images.crossIcon.path),
                        ),
                      ),
                      Text(
                        'Confirm Request',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenColor,
                        ),
                      ),
                      SizedBox(
                        height: 14.h,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Withdraw Amount',
                                style: testStyle(),
                              ),
                              Text(
                                '\$150',
                                style: testStyle(),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Platform Fee (10%)',
                                style: testStyle(),
                              ),
                              Text(
                                '\$15',
                                style: testStyle(
                                  color: AppColors.errorColor,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'You Will Receive',
                                style: testStyle(),
                              ),
                              Text(
                                '\$135',
                                style: testStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 18.h,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        'Depending on the bank, it might \n take one or two working days.',
                        style: TextStyle(
                          color: Color(0Xff4E4E4E),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: 14.h,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        'Are you sure you want to send this \nwithdrawal request?',
                        style: TextStyle(
                          color: Color(0Xff4E4E4E),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: 33.h,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.blackButton,
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.r),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w,),
                          Expanded(
                            child: CustomPrimaryButton(
                              title: 'Yes, Send',
                              onHandler: () {
                                // Get.toNamed(AppRoutes.signInScreen);
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  TextStyle testStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: color ?? AppColors.secondaryTextColor,
      fontSize: fontSize ?? 14.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    );
  }
}
