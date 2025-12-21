// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:ricardo/app/utils/app_colors.dart';
// import 'package:shimmer/shimmer.dart';
//
// class ShimmerHelper {
//   // Base shimmer colors
//   static const Color baseColor = Color(0xFFE0E0E0);
//   static const Color highlightColor = Color(0xFFF5F5F5);
//
//   // Shimmer for horizontal assigned cards
//   static Widget assignedCardsShimmer() {
//     return SizedBox(
//       height: 180.h,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         itemCount: 3,
//         itemBuilder: (context, index) {
//           return Container(
//             width: 140.w,
//             margin: EdgeInsets.only(right: 12.w),
//             child: Shimmer.fromColors(
//               baseColor: baseColor,
//               highlightColor: highlightColor,
//               child: Column(
//                 children: [
//                   // Profile image shimmer
//                   Container(
//                     width: 80.r,
//                     height: 80.r,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   SizedBox(height: 12.h),
//                   // Name shimmer
//                   Container(
//                     width: 100.w,
//                     height: 14.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4.r),
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   // Role shimmer
//                   Container(
//                     width: 70.w,
//                     height: 12.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4.r),
//                     ),
//                   ),
//                   SizedBox(height: 12.h),
//                   // Button shimmer
//                   Container(
//                     width: 120.w,
//                     height: 32.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // Shimmer for upcoming sessions list
//   static Widget upcomingSessionsShimmer({int itemCount = 3}) {
//     return ListView.builder(
//       physics: NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: itemCount,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: EdgeInsets.symmetric(
//             //horizontal: 16.w,
//             vertical: 6.h,
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: Colors.grey.shade200, width: 1),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.03),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Shimmer.fromColors(
//               baseColor: baseColor,
//               highlightColor: highlightColor,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//                 child: Row(
//                   children: [
//                     // Profile image shimmer with subtle border
//                     Container(
//                       width: 56.r,
//                       height: 56.r,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.grey.shade100,
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 14.w),
//                     // Text content shimmer
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Name shimmer - wider
//                           Container(
//                             width: double.infinity,
//                             height: 18.h,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(6.r),
//                             ),
//                           ),
//                           SizedBox(height: 10.h),
//                           // Date/time shimmer - narrower
//                           Container(
//                             width: 140.w,
//                             height: 14.h,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(6.r),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     // Button shimmer with rounded style
//                     Container(
//                       width: 85.w,
//                       height: 32.h,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Combined home screen shimmer
//   static Widget homeScreenShimmer() {
//     return SingleChildScrollView(
//       physics: NeverScrollableScrollPhysics(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Assigned section title shimmer
//           Padding(
//             padding: EdgeInsets.only(
//               top: 24.h,
//               bottom: 24.h,
//               left: 16.w,
//               right: 16.w,
//             ),
//             child: Shimmer.fromColors(
//               baseColor: baseColor,
//               highlightColor: highlightColor,
//               child: Container(
//                 width: 200.w,
//                 height: 20.h,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(4.r),
//                 ),
//               ),
//             ),
//           ),
//           // Assigned cards shimmer
//           assignedCardsShimmer(),
//           // Upcoming sessions title shimmer
//           Padding(
//             padding: EdgeInsets.only(
//               top: 24.h,
//               bottom: 10.h,
//               left: 16.w,
//               right: 16.w,
//             ),
//             child: Shimmer.fromColors(
//               baseColor: baseColor,
//               highlightColor: highlightColor,
//               child: Container(
//                 width: 160.w,
//                 height: 20.h,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(4.r),
//                 ),
//               ),
//             ),
//           ),
//           // Upcoming sessions list shimmer
//           upcomingSessionsShimmer(),
//           SizedBox(height: 44.h),
//         ],
//       ),
//     );
//   }
//
//   // Generic list tile shimmer (reusable)
//   static Widget listTileShimmer({
//     bool showTrailing = true,
//     double? horizontalPadding,
//     double? verticalPadding,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: horizontalPadding ?? 16.w,
//         vertical: verticalPadding ?? 6.h,
//       ),
//       child: Shimmer.fromColors(
//         baseColor: baseColor,
//         highlightColor: highlightColor,
//         child: Container(
//           padding: EdgeInsets.all(12.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8.r),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 48.r,
//                 height: 48.r,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: 16.h,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(4.r),
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Container(
//                       width: 120.w,
//                       height: 14.h,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(4.r),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (showTrailing) ...[
//                 SizedBox(width: 12.w),
//                 Container(
//                   width: 80.w,
//                   height: 25.h,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   static Widget profileViewShimmer() {
//     return SingleChildScrollView(
//       physics: NeverScrollableScrollPhysics(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header section with complete_profile image and name
//           Container(
//             alignment: Alignment.bottomCenter,
//             height: 150.h,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.secondaryColor,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(70.r),
//                 bottomRight: Radius.circular(70.r),
//               ),
//             ),
//             child: Shimmer.fromColors(
//               baseColor: Colors.white.withOpacity(0.3),
//               highlightColor: Colors.white.withOpacity(0.5),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Profile image shimmer
//                   Container(
//                     width: 96.r,
//                     height: 96.r,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 3),
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   // Name shimmer
//                   Container(
//                     width: 150.w,
//                     height: 20.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(6.r),
//                     ),
//                   ),
//                   SizedBox(height: 12.h),
//                 ],
//               ),
//             ),
//           ),
//           // Role shimmer
//           Center(
//             child: Padding(
//               padding: EdgeInsets.only(top: 8.h),
//               child: Shimmer.fromColors(
//                 baseColor: baseColor,
//                 highlightColor: highlightColor,
//                 child: Container(
//                   width: 80.w,
//                   height: 14.h,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(6.r),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 44.h),
//           // Profile details shimmer
//           ...List.generate(6, (index) => _profileDetailItemShimmer()),
//           SizedBox(height: 44.h),
//           // Button shimmer
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Shimmer.fromColors(
//               baseColor: baseColor,
//               highlightColor: highlightColor,
//               child: Container(
//                 width: double.infinity,
//                 height: 48.h,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 44.h),
//         ],
//       ),
//     );
//   }
//
//   // Helper method for complete_profile detail items
//   static Widget _profileDetailItemShimmer() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       child: Shimmer.fromColors(
//         baseColor: baseColor,
//         highlightColor: highlightColor,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title shimmer
//             Container(
//               width: 120.w,
//               height: 16.h,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//             ),
//             SizedBox(height: 8.h),
//             // Subtitle shimmer
//             Container(
//               width: 200.w,
//               height: 14.h,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }