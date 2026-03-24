import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ricardo/gen/assets.gen.dart';

class LogoWidget extends StatelessWidget {
  final double? height, width;
  const LogoWidget({super.key, this.width = 200, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        Assets.images.applogo,
        height: height!.h,
        width: width!.w,
        fit: BoxFit.cover,
      )
    );
  }
}
