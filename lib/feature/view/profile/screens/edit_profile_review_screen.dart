import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/profile/reviews_ratings.dart';
import 'package:ricardo/feature/simmer/review_shimmer.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/services/api_urls.dart';
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
              child: Obx(() {
                if (controller.isReviewsStatus.value) {
                  return const ReviewShimmer();
                }

                if (controller.driverRatings.isEmpty) {
                  return Center(
                    child: Text(
                      'No Reviews found Yet',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return Column(
                  children: [
                    Center(
                      child: Container(
                        width: double.maxFinite,
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
                            buildRatingStars(
                                controller.ratingAverage?.value ?? 0.0),
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
                      (index) {
                        final data = controller.driverRatings[index];
                        final imageFilename =
                            data.passengerUserInfo?.image?.filename;
                        final hasProfileImage = imageFilename != null &&
                            imageFilename.isNotEmpty;

                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: Container(
                            width: double.infinity,
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: hasProfileImage
                                                  ? Image.network(
                                                      '${ApiUrls.imageBaseUrl}$imageFilename',
                                                      height: 40,
                                                      width: 40,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                          Assets.images
                                                              .defaultImage.path,
                                                          height: 40,
                                                          width: 40,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      Assets.images.defaultImage
                                                          .path,
                                                      height: 40,
                                                      width: 40,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            SizedBox(
                                              width: 8.w,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.passengerUserInfo
                                                            ?.name ??
                                                        'Passenger',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontFamily:
                                                          FontFamily.poppins,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  buildRatingStars(
                                                    data.rating ?? 0.0,
                                                    alignment:
                                                        MainAxisAlignment.start,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        displayTime('${data.createdAt}'),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.reviewMinColor,
                                          fontFamily: FontFamily.poppins,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  _ExpandableReviewComment(
                                    comment: data.comment ?? '',
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  Widget buildRatingStars(double rating,
      {MainAxisAlignment alignment = MainAxisAlignment.center}) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (rating >= index + 1) {
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(
              Icons.star,
              color: Colors.orange,
              size: 16.sp,
            ),
          );
        } else if (rating >= index + 0.1) {
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(
              Icons.star_half_rounded,
              color: Colors.orange,
              size: 16.sp,
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(
              Icons.star_border,
              color: Colors.orange,
              size: 16.sp,
            ),
          );
        }
      }),
    );
  }
}

class _ExpandableReviewComment extends StatefulWidget {
  const _ExpandableReviewComment({required this.comment});

  final String comment;

  @override
  State<_ExpandableReviewComment> createState() =>
      _ExpandableReviewCommentState();
}

class _ExpandableReviewCommentState extends State<_ExpandableReviewComment> {
  static const int _maxCollapsedChars = 100;
  static const int _maxCollapsedLines = 2;

  bool _expanded = false;

  TextStyle get _commentStyle => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.richTextColor,
        fontFamily: FontFamily.poppins,
        letterSpacing: 1.1,
        height: 1.4,
      );

  TextStyle get _actionStyle => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
        fontFamily: FontFamily.poppins,
      );

  bool _shouldShowSeeMore(String text, double maxWidth) {
    if (text.length > _maxCollapsedChars) return true;

    final painter = TextPainter(
      text: TextSpan(text: text, style: _commentStyle),
      maxLines: _maxCollapsedLines,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment.trim();
    if (comment.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
        final showSeeMore =
            !_expanded && _shouldShowSeeMore(comment, constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment,
              style: _commentStyle,
              textAlign: TextAlign.start,
              maxLines: _expanded ? null : _maxCollapsedLines,
              overflow:
                  _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (showSeeMore)
              GestureDetector(
                onTap: () => setState(() => _expanded = true),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text('See more', style: _actionStyle),
                ),
              ),
            if (_expanded && _shouldShowSeeMore(comment, constraints.maxWidth))
              GestureDetector(
                onTap: () => setState(() => _expanded = false),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text('See less', style: _actionStyle),
                ),
              ),
          ],
        );
      },
      ),
    );
  }
}
