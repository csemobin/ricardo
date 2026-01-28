import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/profile/reviews_ratings.dart';
import 'package:ricardo/feature/simmer/review_shimmer.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/widgets.dart';

class EditProfileReviewScreen extends StatefulWidget {
  const EditProfileReviewScreen({super.key});

  @override
  State<EditProfileReviewScreen> createState() =>
      _EditProfileReviewScreenState();
}

class _EditProfileReviewScreenState extends State<EditProfileReviewScreen> {
  final controller = Get.put(ReviewsRatingsController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchReviewRating();
    });
  }

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
      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchReviewRating();
        },
        child: LayoutBuilder(builder: (context, containers) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: containers.maxHeight,
              ),
              child: Obx((){

                if (controller.isReviewsStatus.value) {
                  return const ReviewShimmer(); // your new shimmer
                }

                if (controller.driverRatings.isEmpty) {
                  return Center(
                    child: Text(
                      'No Reviews found Yet',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return Column(
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
                              '${controller.ratingAverage}',
                              style: TextStyle(
                                fontSize: 52.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cardTitle,
                              ),
                            ),
                            buildRatingStars(controller.ratingAverage?.value ?? 0.0),
                            SizedBox(
                              height: 8.h,
                            ),
                            Text(
                              '${controller.totalRatings} Reviews',
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

                      controller.driverRatings.length,
                          (index){
                            final data = controller.driverRatings[index];
                            return Padding(
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
                                                        // '${ApiUrls.imageBaseUrl}${data.passengerUserInfo}',
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
                                                          '${data.passengerUserInfo?.name}',
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight: FontWeight.w500,
                                                            color:
                                                            AppColors.primaryColor,
                                                            fontFamily:
                                                            FontFamily.poppins,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5.h,
                                                        ),
                                                        buildRatingStars(data.rating ?? 0.0)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Text(
                                              displayTime('${data.createdAt}'),
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
                                          '${data.comment}',
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.richTextColor,
                                              fontFamily: FontFamily.poppins,
                                              letterSpacing: 1.1),
                                        )
                                      ],
                                    ),
                                  )),
                            );
                          },
                    ),
                  ],
                );
              }),
            ),
          );
        }),
      ),
    );
  }
  String displayTime(String createdAt) {
    try {
      final utcTime = DateTime.parse(createdAt);
      final localTime = utcTime.toLocal();

      final now = DateTime.now();
      final difference = now.difference(localTime);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} min ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
      } else {
        return DateFormat('dd MMM yyyy').format(localTime);
      }
    } catch (e) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    }
  }

  // Rating related work are here
  Widget buildRatingStars(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (rating >= index + 1) {
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(Icons.star,color: Colors.orange,),
          );
        } else if (rating >= index + 0.1) {
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(Icons.star_half_rounded, color: Colors.orange,),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(Icons.star_border, color: Colors.orange,),
          );
        }
      }),
    );
  }


}
