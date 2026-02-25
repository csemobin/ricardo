import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 12,
      separatorBuilder: (_, __) => SizedBox(height: 5.h),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListTile(
            leading: Container(
              height: 40.h,
              width: 40.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            title: Container(
              height: 12.h,
              width: double.infinity,
              color: Colors.white,
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Container(
                height: 10.h,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}