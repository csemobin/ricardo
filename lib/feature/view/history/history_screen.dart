import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        centerTitle: true,
        title: Text(
          'History',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 30.h,
            decoration: BoxDecoration(color: AppColors.navBarBackgroundColor),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 25.w,
                vertical: 5.h,
              ),
              child: Text(
                'Today',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackBText,
                    fontFamily: FontFamily.poppins),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppColors.whiteColor),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 5.h,
                horizontal: 25.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '25 June 2024, 04:40 PM',
                        style: textStyle(),
                      ),
                      Text(
                        '\$11',
                        style: textStyle(),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      Image.asset(Assets.images.directRight.path),
                      SizedBox(
                        width: 8.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PICK UP',
                            style: TextStyle(
                              color: AppColors.labelTextColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.poppins,
                            ),
                          ),
                          Text(
                            'Block B, Banasree, Dhaka.',
                            style: textStyle(),
                          )
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 4.w,
                    ),
                    child: Container(
                      width: 2.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: AppColors.separaterBgColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(Assets.images.location.path),
                      SizedBox(
                        width: 8.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DROP OFF',
                            style: TextStyle(
                              color: AppColors.labelTextColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.poppins,
                            ),
                          ),
                          Text(
                            'Dhanmondi, Dhaka.',
                            style: textStyle(),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle textStyle() {
    return TextStyle(
      color: AppColors.primaryHeadingTextColor,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      fontFamily: FontFamily.poppins,
    );
  }
}
