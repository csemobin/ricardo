import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';

class NoInternetMessageMap extends StatelessWidget {
  const NoInternetMessageMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      width: double.maxFinite,
      color: Color(0XFFEBEBEB),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(
              left: 30,
            ),
            child: Image.asset(Assets.images.offline.path),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You\'re Offline!',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0XFF171717),
                    fontFamily: FontFamily.poppins),
              ),
              Text(
                'Go online to start accepting jobs. ',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: FontFamily.poppins,
                    color: AppColors.secondaryTextColor),
              ),
            ],
          )
        ],
      ),
    );
  }
}
