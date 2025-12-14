// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// // import 'package:shimmer/shimmer.dart';
//
// class CustomNetworkImage extends StatelessWidget {
//   final String imageUrl;
//   final double? height;
//   final double? width;
//   final Border? border;
//   final double? borderRadius;
//   final BoxShape boxShape;
//   final Color? backgroundColor;
//   final Widget? child;
//   final ColorFilter? colorFilter;
//   final List<BoxShadow>? boxShadow;
//   final bool elevation;
//   final BoxFit? fit;
//
//   const CustomNetworkImage(
//       {super.key,
//       this.child,
//       this.colorFilter,
//       required this.imageUrl,
//       this.backgroundColor,
//        this.height,
//        this.width,
//       this.border,
//       this.borderRadius,
//       this.boxShape = BoxShape.rectangle, this.boxShadow,  this.elevation = false, this.fit,});
//
//   @override
//   Widget build(BuildContext context) {
//     return CachedNetworkImage(
//       fit: fit ?? BoxFit.cover,
//         imageUrl: imageUrl,
//         imageBuilder: (context, imageProvider) => Container(
//               height: height,
//               width: width,
//               decoration: BoxDecoration(
//                 boxShadow: boxShadow ??
//                     (elevation
//                         ? [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.06),
//                         blurRadius: 20,
//                         spreadRadius: 6,
//                       ),
//                     ]
//                         : null),
//                 border: border,
//                 borderRadius: borderRadius != null ?  BorderRadius.circular(borderRadius ?? 0) : null,
//                 shape: boxShape,
//                 color: backgroundColor,
//                 image: DecorationImage(
//                     image: imageProvider,
//                     fit: fit ?? BoxFit.cover,
//                     colorFilter: colorFilter),
//               ),
//               child: child,
//             ),
//         placeholder: (context, url) => Shimmer.fromColors(
//             baseColor: Colors.grey.withOpacity(0.6),
//             highlightColor: Colors.grey.withOpacity(0.3),
//             child: Container(
//               height: height,
//               width: width,
//               decoration: BoxDecoration(
//                 boxShadow: boxShadow ??
//                     (elevation
//                         ? [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.06),
//                         blurRadius: 20,
//                         spreadRadius: 6,
//                       ),
//                     ]
//                         : null),
//                 border: border,
//                 color: Colors.grey.withOpacity(0.6),
//                 borderRadius: borderRadius != null ?  BorderRadius.circular(borderRadius ?? 0) : null,
//                 shape: boxShape,
//               ),
//             )),
//         errorWidget: (context, url, error) => Container(
//               height: height,
//               width: width,
//               decoration: BoxDecoration(
//                 boxShadow: boxShadow ??
//                     (elevation
//                         ? [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.06),
//                         blurRadius: 20,
//                         spreadRadius: 6,
//                       ),
//                     ]
//                         : null),
//                 border: border,
//                 color: Colors.transparent,
//                 borderRadius: borderRadius != null ?  BorderRadius.circular(borderRadius ?? 0) : null,
//                 shape: boxShape,
//               ),
//               child: const Icon(Icons.broken_image_outlined,color: Colors.grey,),
//             ));
//   }
// }
