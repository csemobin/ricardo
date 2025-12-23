import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/widgets.dart';

class EditProfileReviewScreen extends StatelessWidget {
  EditProfileReviewScreen({super.key});

  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          'Reviews',
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
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '4.0',
                          style: TextStyle(
                            fontSize: 52.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cardTitle,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Assets.images.rattingStar.path),
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(Assets.images.rattingStar.path),
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(Assets.images.rattingStar.path),
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(Assets.images.rattingStar.path),
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(Assets.images.rattingStar.path),
                          ],
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          '52 Reviews',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...List.generate(
                  10,
                  (index) => Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                    child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(6.r)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: Image.asset(
                                              Assets.images.reviewImage.path,
                                              height: 40,
                                              width: 40,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8.w,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Courtney Henry',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.primaryColor,
                                                  fontFamily:
                                                      FontFamily.poppins,
                                                ),
                                              ),
                                              SizedBox(height: 5.h,),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(Assets
                                                      .images.rattingStar.path),
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  Image.asset(Assets
                                                      .images.rattingStar.path),
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  Image.asset(Assets
                                                      .images.rattingStar.path),
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  Image.asset(Assets
                                                      .images.rattingStar.path),
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  Image.asset(Assets
                                                      .images.rattingStar.path),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '2 mins ago',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.reviewMinColor,
                                      fontFamily: FontFamily.poppins,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                'Consequat velit qui adipisicing sunt rependerit ad laborum tempor ullamco exercitation. Umco tempor adipisicing et voluptate aaiugdh aiughdu',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.richTextColor,
                                  fontFamily: FontFamily.poppins,
                                  letterSpacing: 1.1
                                ),
                              )
                            ],
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
