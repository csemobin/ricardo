// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../app/utils/app_colors.dart';
// import '../services/api_urls.dart';
// import '../widgets/widgets.dart';
//
// class CustomImageAvatar extends StatelessWidget {
//   const CustomImageAvatar({
//     super.key,
//     this.radius = 26,
//     this.image,
//     this.top,
//     this.bottom,
//     this.left,
//     this.right,
//     this.fileImage,  this.showBorder = false,
//   });
//
//   final double radius;
//   final String? image;
//   final File? fileImage;
//   final double? top;
//   final double? bottom;
//   final double? left;
//   final double? right;
//   final bool showBorder;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         top: top ?? 0,
//         right: right ?? 0,
//         left: left ?? 0,
//         bottom: bottom ?? 0,
//       ),
//       child: Container(
//         padding: EdgeInsets.all(showBorder ? 1.r : 0),
//         decoration: const BoxDecoration(
//           color: AppColors.primaryColor,
//           shape: BoxShape.circle,
//         ),
//         child: CircleAvatar(
//           radius: radius.r,
//           backgroundColor: Colors.grey.shade200,
//           child: fileImage != null
//               ? ClipOval(
//             child: Image.file(
//               fileImage!,
//               width: 2 * radius.r,
//               height: 2 * radius.r,
//               fit: BoxFit.cover,
//             ),
//           )
//               : CustomNetworkImage(
//             boxShape: BoxShape.circle,
//             imageUrl: (image != null && image!.isNotEmpty)
//                 ? "$image"
//                 : "https://templates.joomla-monster.com/joomla30/jm-news-portal/components/com_djclassifieds/assets/images/default_profile.png",
//           ),
//         ),
//       ),
//     );
//   }
// }
