import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/helper_data.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_button.dart';
import 'package:ricardo/widgets/custom_container.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      body: Container(
        width: double.infinity,
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Color(0x00FFFFFF),
              Color(0x4DE1FF00),
            ],
            stops: const [0.0, 0.9],
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              physics: const ClampingScrollPhysics(),
              controller: _pageController,
              itemCount: HelperData.onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final data = HelperData.onboardingData[index];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              SizedBox(height: constraints.maxHeight * 0.15),
                              Flexible(
                                flex: 2,
                                child: Image.asset(
                                  data['image'],
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 32.h),
                              CustomText(
                                right: 24.w,
                                left: 24.w,
                                top: 32.h,
                                text: data['title'],
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                                letterSpacing: 1,
                                fontName: FontFamily.inter,
                              ),
                              CustomText(
                                right: 30.w,
                                left: 30.w,
                                top: 16.h,
                                text: data['subtitle'],
                                fontSize: 14.sp,
                                textHeight: 1.5,
                                color: AppColors.secondaryTextColor,
                                fontName: FontFamily.inter,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(height: constraints.maxHeight * 0.15),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned(
              top: 0.h,
              left: 24.w,
              right: 24.w,
              child: SafeArea(
                top: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.applogo,
                      width: 100.w,
                      height: 100.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          HelperData.onboardingData.length - 1,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(fontSize: 16.sp, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10.h,
              left: 24.w,
              right: 24.w,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 100,
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: HelperData.onboardingData.length,
                        effect: ExpandingDotsEffect(
                          dotColor: Color(0XffA1A1A1),
                          activeDotColor: Color(0xff007635),
                          dotHeight: 8.h,
                          dotWidth: 8.w,
                        ),
                      ),
                      if (!(currentIndex ==
                          HelperData.onboardingData.length - 1))
                        CustomContainer(
                          onTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          paddingAll: 14.r,
                          shape: BoxShape.circle,
                          child: SvgPicture.asset(Assets.icons.button),
                        ),
                      if (currentIndex ==
                          HelperData.onboardingData.length - 1)
                        CustomButton(
                          width: 160.w,
                          height: 60.h,
                          radius: 100.r,
                          onPressed: () =>
                              Get.offAllNamed(AppRoutes.authInitialScreen),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                              BorderRadius.all(Radius.circular(100.r)),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Color(0Xff007635),
                                  borderRadius: BorderRadius.circular(30.r)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CustomContainer(
                                    color: Colors.white,
                                    paddingAll: 10.r,
                                    shape: BoxShape.circle,
                                    child: Icon(
                                      Icons.arrow_right_alt,
                                      color: Color(0Xff007635),
                                      size: 28,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}