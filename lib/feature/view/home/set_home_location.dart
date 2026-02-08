import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class SetHomeLocation extends StatefulWidget {
  const SetHomeLocation({super.key});

  @override
  State<SetHomeLocation> createState() => _SetHomeLocationState();
}

class _SetHomeLocationState extends State<SetHomeLocation> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text(
          'Set Your Home Location',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: FontFamily.poppins,
          ),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 24.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.locationBgColor,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Image.asset(
                      Assets.images.greyBookmark.path,
                      height: 19.h,
                      width: 19.h,
                    ),
                  ),
                  Text(
                    'Search address',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: FontFamily.poppins,
                      color: Color(0xff929292),
                    ),
                  ),
                ],
              ),
              Image.asset(
                Assets.images.greySearch.path,
                height: 19.h,
                width: 19.h,
              ),
            ],
          ),
          SizedBox(
            height: 22.h,
          ),
          // Map related Work
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.locationBgColor,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Image.asset(
                      Assets.images.greyMap.path,
                      height: 19.h,
                      width: 19.h,
                    ),
                  ),
                  Text(
                    'Set On Map',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: FontFamily.poppins,
                      color: Color(0xff929292),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 64.h,
          ),
          //Confirm Address button
          CustomPrimaryButton(
            title: 'Confirm Address',
            onHandler: () {},
          )
        ],
      ),
    );
  }
}
