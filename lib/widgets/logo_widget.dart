import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/gen/assets.gen.dart';

class LogoWidget extends StatelessWidget {
  final double? height, width;
  const LogoWidget({super.key, this.width = 200, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        Assets.images.applogo.path,
        height: height!.h,
        width: width!.w,
        fit: BoxFit.cover,
      )
    );
  }
}
