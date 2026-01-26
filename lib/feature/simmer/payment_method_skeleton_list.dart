import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/feature/simmer/skeleton.dart';

class PaymentMethodSkeletonList extends StatelessWidget {
  const PaymentMethodSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, __) {
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 18.r,
                  horizontal: 12.r,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    Skeleton(
                      height: 30.h,
                      width: 50.w,
                    ),
                    SizedBox(width: 13.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(
                          height: 14.h,
                          width: 140.w,
                        ),
                        SizedBox(height: 6.h),
                        Skeleton(
                          height: 10.h,
                          width: 100.w,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Skeleton(
              height: 24.h,
              width: 24.w,
              borderRadius: BorderRadius.circular(50),
            ),
          ],
        );
      },
    );
  }
}
