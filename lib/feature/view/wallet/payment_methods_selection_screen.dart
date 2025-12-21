import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class PaymentMethodsSelectionScreen extends StatelessWidget {
  const PaymentMethodsSelectionScreen({super.key});

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
            child: ListView.separated(
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
                            Image.asset(Assets.images.visa.path,fit: BoxFit.contain,),
                            SizedBox(
                              width: 13.w,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '**** **** **** 8970',
                                  style: TextStyle(
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
                    SizedBox(
                      width: 10.w,
                    ),
                    Image.asset(Assets.images.removeBusket.path),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 8.h,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
