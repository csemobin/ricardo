// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../app/utils/app_colors.dart';
// import '../widgets/widgets.dart';
//
//
// class ChatsListTileWidget extends StatelessWidget {
//   const ChatsListTileWidget({
//     super.key,
//     this.images,
//     this.names,
//     this.message,
//     this.time,
//     this.label,
//     this.unreadMessage = false,
//     this.isGroup = false, this.onTap,
//   });
//
//   final List<String>? images;
//   final String? names;
//   final String? message;
//   final String? time;
//   final bool unreadMessage;
//   final String? label;
//   final bool isGroup;
//   final VoidCallback? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: onTap,
//       contentPadding: EdgeInsets.zero,
//       leading: isGroup
//           ? groupAvatarWidget(images ?? [],Colors.green)
//           : CustomImageAvatar(
//               radius: 24.r,
//               image: images?.first ?? '',
//             ),
//       title: Row(
//         children: [
//           Flexible(
//             child: CustomText(
//               textAlign: TextAlign.start,
//               text: names ?? '',
//               maxline: 1,
//               textOverflow: TextOverflow.ellipsis,
//               //fontName: FontFamily.uncut,
//             ),
//           ),
//           if (label != null && !isGroup) ...[
//             SizedBox(width: 4.w),
//             CustomContainer(
//               radiusAll: 4,
//               color: Colors.white,
//               paddingVertical: 2.h,
//               paddingHorizontal: 4.h,
//               child: FittedBox(
//                 child: CustomText(
//                   text: label ?? '',
//                   //fontName: FontFamily.uncut,
//                   fontSize: 11.sp,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//       subtitle: Row(
//         children: [
//           Flexible(
//             child: CustomText(
//               right: 4.w,
//               textAlign: TextAlign.start,
//               fontSize: 12.sp,
//               text: message ?? '',
//               maxline: 1,
//               textOverflow: TextOverflow.ellipsis,
//              // fontName: FontFamily.uncut,
//               color: AppColors.secondaryColor,
//             ),
//           ),
//           Icon(
//             Icons.circle,
//             color: AppColors.secondaryColor,
//             size: 4.r,
//           ),
//           CustomText(
//             left: 4.w,
//             textAlign: TextAlign.start,
//             fontSize: 12.sp,
//             text: time ?? '',
//             maxline: 1,
//             textOverflow: TextOverflow.ellipsis,
//             //fontName: FontFamily.uncut,
//             color: AppColors.secondaryColor,
//           ),
//         ],
//       ),
//       trailing: unreadMessage
//           ? CustomText(
//               textAlign: TextAlign.start,
//               fontSize: 12.sp,
//               text: 'New',
//               fontWeight: FontWeight.w600,
//              // fontName: FontFamily.uncut,
//             )
//           : null,
//     );
//   }
//
//   Widget groupAvatarWidget(List<String> imagePaths, Color? activeColor, {String? heroTag}) {
//     final maxVisible = 2;
//     final visibleImages = imagePaths.take(maxVisible).toList();
//
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         SizedBox(
//           width: 50.w,
//           height: 50.h,
//           child: Stack(
//             children: [
//               for (int i = 0; i < visibleImages.length; i++)
//                 Positioned(
//                   bottom: i * 10.w,
//                   left: i * 10.w,
//                   child: CustomImageAvatar(
//                      radius: 14.r,
//                       image: visibleImages[i]),
//                 ),
//             ],
//           ),
//         ),
//         if (activeColor != null)
//           Positioned(
//             right: 2.w,
//             bottom: 0,
//             child: Container(
//               padding: EdgeInsets.all(1.5.r),
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white,
//               ),
//               child: Icon(
//                 Icons.circle,
//                 size: 12.r,
//                 color: activeColor,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
