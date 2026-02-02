import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/wallet/payment_method_controller.dart';
import 'package:ricardo/feature/controllers/wallet/withdraw_request_controller.dart';
import 'package:ricardo/feature/simmer/payment_method_skeleton_list.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class WithdrawRequestScreen extends StatefulWidget {
  const WithdrawRequestScreen({super.key});

  @override
  State<WithdrawRequestScreen> createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final paymentController = Get.put(PaymentMethodController());
  final withdrawController = Get.put(WithdrawRequestController());

  @override
  void initState() {
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        paymentController.fetchPaymentCardInfo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text('Withdraw Request'),
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(
          overscroll: false,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: CustomTextField(
                  controller: withdrawController.amountTEController,
                  hintText: 'Enter Amount',
                  labelText: 'Enter Amount',
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 18.h),

              // Select Card Section
              Text(
                'Select Card',
                style: AppCustomDesign.walletScreenTextStyle,
              ),
              SizedBox(height: 15.h),

              // Card List
              Obx(() {
                if (paymentController.paymentCardInfoStatus.value == true) {
                  return PaymentMethodSkeletonList();
                }
                if (paymentController.paymentCardInfo.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50.h),
                      child: Text('No Card Added Yet'),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: paymentController.paymentCardInfo.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final bankInfo = paymentController.paymentCardInfo[index];
                    return Obx(() {
                      final isSelected =
                          withdrawController.selectedCard.value?.sId ==
                              bankInfo?.sId;

                      return GestureDetector(
                        onTap: () {
                          withdrawController.selectCard(bankInfo);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 18.r, horizontal: 12.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(Assets.images.visa.path),
                              SizedBox(width: 13.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '**** **** **** ${bankInfo!.accountNumber!.substring(bankInfo.accountNumber!.length - 4)}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Bank: ${bankInfo.bankName}',
                                    style: TextStyle(fontSize: 10.sp),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                );
              }),

              SizedBox(height: 25.h),

              // Add Payment Button
              Obx(() {
                return GestureDetector(
                  onTap: () {
                    if (paymentController.paymentCardInfo.length < 3) {
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
                      color: paymentController.paymentCardInfo.length >= 3
                          ? AppColors.blackButton.withOpacity(0.5)
                          : AppColors.blackButton,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(Assets.images.paymentMethodIcon.path),
                        SizedBox(width: 20.w),
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
              SizedBox(height: 14.h),
              Obx(() {
                return CustomPrimaryButton(
                  title: 'Withdraw',
                  // isDisable: !withdrawController.isFormValid.value,
                  onHandler: withdrawController.isFormValid.value == true
                      ? () {
                          confirmRequestPopupModal(context);
                        }
                      : null,
                );
              }),
              SizedBox(height: 40.h),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 18.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: Color(0x0D01AF44),
                ),
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
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  // Confirm Withdraw Request Pop up Model are here
  void confirmRequestPopupModal(BuildContext context) {
    // Amount Related work are here
    final amountString = withdrawController.amountTEController.text;
    final amount = double.tryParse(amountString) ?? 0.0;

    // Tax Related work are here - CORRECTED
    final taxString = dotenv.env['APP_TAX'] ?? '0'; // Get from .env
    final taxPercentage = double.tryParse(taxString) ?? 0.0; // Parse to double

    // Calculate platform fee
    final platformFee = amount * (taxPercentage / 100);

    // Calculate net amount
    final netAmount = amount - platformFee;

    showDialog(
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white.withOpacity(0.8),
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r), // Changed: 12px radius
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 4, // Changed: Reduced blur for glass effect
                  sigmaY: 4,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    // Added: Fixed size
                    minWidth: 345.w,
                    maxWidth: 345.w,
                    minHeight: 382.h,
                    maxHeight: 382.h,
                  ),
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.3),
                    // Changed: 30% opacity
                    borderRadius: BorderRadius.circular(12.r),
                    // Changed: 12px radius
                    border: Border.all(
                        color: AppColors.whiteColor.withOpacity(0.3)),
                    boxShadow: [
                      // Added: Box shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(0, -4),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                          alignment: Alignment.topRight, // Changed: topRight
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
                                '\$${withdrawController.amountTEController.text}',
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
                                'Platform Fee (${dotenv.env['APP_TAX']}) %)',
                                style: testStyle(),
                              ),
                              Text(
                                '\$${platformFee.toStringAsFixed(2)}',
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
                                '\$${netAmount.toStringAsFixed(2)}',
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
                          color: Colors.black,
                          // Changed: Black color for readability
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
                          color: Colors.black,
                          // Changed: Black color for readability
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
                            child: GestureDetector(
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
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(child: Obx(() {
                            return CustomPrimaryButton(
                              title: withdrawController
                                          .isWithdrawRequestStatus.value ==
                                      true
                                  ? 'Confirming...'
                                  : 'Yes, Send',
                              onHandler: () {
                                withdrawController.withdrawRequestHandler();
                                Navigator.pop(context);
                              },
                            );
                          }))
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

  // Confirmation Pop Up Model are here
  void confirmationPopupModal(BuildContext context) {
    showDialog(
        barrierDismissible: true,
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
                      color: AppColors.whiteColor.withOpacity(0.15),
                      border: Border.all(color: Colors.white.withOpacity(0.8))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(padding: EdgeInsets.only(top: 32.h)),
                      Image.asset(Assets.images.glassmorphismLogo.path),
                      SizedBox(
                        height: 30.h,
                      ),
                      Text(
                        'Successfully Submitted',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenColor,
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        'Your withdraw request send successfully',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      CustomPrimaryButton(
                        title: 'Back to Home',
                        onHandler: () {
                          Get.offAllNamed(AppRoutes.customBottomNavBar);
                          Get.find<CustomBottomNavBarController>().onChange(0);
                        },
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
      color: color ?? AppColors.darkColor,
      fontSize: fontSize ?? 14.sp,
      fontWeight: fontWeight ?? FontWeight.w500,
    );
  }
}
