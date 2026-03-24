import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/feature/controllers/wallet/payment_method_controller.dart';
import 'package:ricardo/feature/simmer/payment_method_skeleton_list.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class PaymentMethodsSelectionScreen extends StatefulWidget {
  const PaymentMethodsSelectionScreen({super.key});

  @override
  State<PaymentMethodsSelectionScreen> createState() =>
      _PaymentMethodsSelectionScreenState();
}

class _PaymentMethodsSelectionScreenState
    extends State<PaymentMethodsSelectionScreen> {
  final controller = Get.put(PaymentMethodController());

  @override
  void initState() {
    super.initState();
    controller.fetchPaymentCardInfo();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text('Payment Methods'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38.h,
          ),

          // Button Related Work are here
          Obx(() {
            return GestureDetector(
              onTap: () {
                if (controller.paymentCardInfo.length < 3) {
                  Get.toNamed(AppRoutes.addCardScreen);
                } else {
                  Get.snackbar(
                    'Limit Reached',
                    'You can only add up to 3 cards',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: controller.paymentCardInfo.length >= 3
                      ? AppColors.blackButton.withOpacity(0.5)
                      : AppColors.blackButton,
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
            );
          }),
          SizedBox(
            height: 38.h,
          ),

          // Bank Info and there Bottom Section work are here
          Text(
            'Bank Info',
            style: AppCustomDesign.walletScreenTextStyle,
          ),
          SizedBox(
            height: 15.h,
          ),
          Expanded(
            child: Obx(() {
              if (controller.paymentCardInfoStatus.value == true) {
                return PaymentMethodSkeletonList();
              }
              if ( controller.paymentCardInfo.isEmpty ) {
                return Center(
                  child: Text('No Card Added Yet'),
                );
              }
              return ListView.separated(
                itemCount: controller.paymentCardInfo.length,
                itemBuilder: (context, index) {
                  final bankInfo = controller.paymentCardInfo[index];
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
                              Image.asset(
                                Assets.images.visa.path,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(
                                width: 13.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '**** **** **** ${bankInfo?.accountNumber != null && bankInfo!.accountNumber!.length >= 4 ? bankInfo.accountNumber!.substring(bankInfo.accountNumber!.length - 4) : ''}',
                                    style: TextStyle(
                                      color: AppColors.cardTitle,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Bank: ${bankInfo?.bankName}.',
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
                      SizedBox(
                        width: 10.w,
                      ),
                      InkWell(
                        child: Image.asset(Assets.images.removeBusket.path),
                        onTap: () =>
                            showPopUp(bankInfo!.sId.toString(), context),
                      )
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 8.h,
                  );
                },
              );
            }),
          ),
        ],
      )
    );
  }

  void showPopUp(String cardId, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
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
                    color: AppColors.whiteColor.withOpacity(0.15),
                    border: Border.all(color: Colors.white.withOpacity(0.8))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding: EdgeInsets.only(top: 32.h)),
                    SvgPicture.asset(Assets.images.glassmorphismLogo),
                    SizedBox(
                      height: 30.h,
                    ),
                    Text(
                      'Are you want to delete ?',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greyColor300,
                              foregroundColor: AppColors.blackButton,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Obx(() {
                          return Expanded(
                            child: ElevatedButton(
                              onPressed: controller.isCardDelete.value
                                  ? null // Disable button while loading
                                  : () async {
                                final res = await controller.deletePaymentCard(cardId);
                                if (res && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorColor,
                                foregroundColor: AppColors.whiteColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                side: BorderSide(
                                  color: AppColors.errorColor,
                                ),
                              ),
                              child: Text(controller.isCardDelete.value ? 'Deleting...' : 'Delete')
                            ),
                          );
                        }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
