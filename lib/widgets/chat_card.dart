// import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:ricardo/app/helpers/time_format.dart';
// import 'package:ricardo/app/utils/app_colors.dart';
// import 'package:ricardo/services/api_urls.dart';
// import 'package:ricardo/widgets/widgets.dart';
// import 'package:audioplayers/audioplayers.dart';
//
// class ChatBubbleMessage extends StatelessWidget {
//   final String time;
//   final String? text;
//   final List<String>? images;
//   final List<String>? audioUrls; // List হিসেবে নিন
//   final bool isSeen;
//   final bool isMe;
//   final String status;
//   final String? profileImage;
//
//   const ChatBubbleMessage({
//     super.key,
//     required this.time,
//     this.text,
//     this.images,
//     this.audioUrls,
//     required this.isMe,
//     this.isSeen = false,
//     this.status = 'offline',
//     this.profileImage,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
//       child: Column(
//         crossAxisAlignment:
//         isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment:
//             isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (!isMe)
//                 CustomImageAvatar(
//                   image: profileImage,
//                   right: 8.w,
//                   radius: 15.r,
//                 ),
//               Flexible(
//                 child: CustomContainer(
//                   paddingAll: 10.r,
//                   color: isMe ? const Color(0xff666978) : const Color(0xffE8E9EB),
//                   bottomRight: 10.r,
//                   bottomLeft: 10.r,
//                   topLeftRadius: isMe ? 10.r : 0,
//                   topRightRadius: !isMe ? 10.r : 0,
//                   child: _buildMessageContent(),
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//             padding: EdgeInsets.only(
//               left: isMe ? 0 : 44.w,
//               right: isMe ? 10.w : 0,
//               top: 3.h,
//             ),
//             child: CustomText(
//               fontSize: 10.sp,
//               fontWeight: FontWeight.w400,
//               text: TimeFormatHelper.timeFormat(time),
//               color: AppColors.appGreyColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageContent() {
//     // অডিও মেসেজ শো করার জন্য
//     if (audioUrls != null && audioUrls!.isNotEmpty) {
//       return AudioPlayerWidget(audioUrls: audioUrls!, isMe: isMe);
//     }
//     // টেক্সট মেসেজ শো করার জন্য
//     else if (text?.isNotEmpty == true) {
//       return CustomText(
//         maxline: 10,
//         fontSize: 12.sp,
//         textAlign: TextAlign.left,
//         fontWeight: FontWeight.w400,
//         color: isMe ? Colors.white : Colors.grey.shade800,
//         text: text!,
//       );
//     }
//     // ইমেজ মেসেজ শো করার জন্য
//     else if (images != null && images!.isNotEmpty) {
//       return SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: images!.map((url) {
//             return Padding(
//               padding: EdgeInsets.only(right: 5.h),
//               child: SizedBox(
//                 width: 188.w,
//                 child: BubbleNormalImage(
//                   id: url ?? '',
//                   image: CustomNetworkImage(
//                     imageUrl: url,
//                     fit: BoxFit.cover,
//                   ),
//                   color: Colors.transparent,
//                   tail: true,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     }
//     return const SizedBox();
//   }
// }
//
// class AudioPlayerWidget extends StatefulWidget {
//   final List<String> audioUrls;
//   final bool isMe;
//
//   const AudioPlayerWidget({
//     super.key,
//     required this.audioUrls,
//     required this.isMe,
//   });
//
//   @override
//   State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
// }
//
// class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
//     with SingleTickerProviderStateMixin {
//   final AudioPlayer _player = AudioPlayer();
//   bool _isPlaying = false;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//
//   late AnimationController _eqController;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _eqController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//
//     _player.onDurationChanged.listen((d) {
//       setState(() => _duration = d);
//     });
//
//     _player.onPositionChanged.listen((p) {
//       setState(() => _position = p);
//     });
//
//     _player.onPlayerComplete.listen((_) {
//       setState(() {
//         _isPlaying = false;
//         _position = Duration.zero;
//       });
//       _eqController.stop();
//     });
//   }
//
//   Future<void> _playPause() async {
//     if (_isPlaying) {
//       await _player.pause();
//       _eqController.stop();
//     } else {
//       await _player.play(
//         UrlSource(widget.audioUrls.first),
//       );
//       _eqController.repeat();
//     }
//
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }
//
//   String _fmt(Duration d) {
//     return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
//   }
//
//   @override
//   void dispose() {
//     _player.dispose();
//     _eqController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       constraints: BoxConstraints(maxWidth: 250.w),
//       decoration: BoxDecoration(
//         color: widget.isMe ? const Color(0xff666978) : const Color(0xffE8E9EB),
//         borderRadius: BorderRadius.circular(14.r),
//       ),
//       child: Row(
//         children: [
//           // PLAY BUTTON
//           GestureDetector(
//             onTap: _playPause,
//             child: Container(
//               padding: EdgeInsets.all(6.r),
//               decoration: BoxDecoration(
//                 color: widget.isMe
//                     ? Colors.white.withOpacity(0.25)
//                     : Colors.grey.shade300,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 _isPlaying ? Icons.pause : Icons.play_arrow,
//                 color: widget.isMe ? Colors.white : Colors.black87,
//                 size: 18.r,
//               ),
//             ),
//           ),
//
//           SizedBox(width: 10.w),
//
//           // EQUALIZER BARS
//           AnimatedBuilder(
//             animation: _eqController,
//             builder: (_, __) {
//               return Row(
//                 children: List.generate(6, (i) {
//                   double height = 6 + (10 * (i % 2 == 0 ? _eqController.value : (1 - _eqController.value)));
//                   return Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 2.w),
//                     child: Container(
//                       width: 3.w,
//                       height: height.h,
//                       decoration: BoxDecoration(
//                         color: widget.isMe
//                             ? Colors.white
//                             : Colors.black87,
//                         borderRadius: BorderRadius.circular(4.r),
//                       ),
//                     ),
//                   );
//                 }),
//               );
//             },
//           ),
//
//           Spacer(),
//
//           // TIME TEXT
//           Text(
//             _fmt(_position),
//             style: TextStyle(
//               fontSize: 10.sp,
//               color: widget.isMe
//                   ? Colors.white.withOpacity(0.7)
//                   : Colors.grey.shade700,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
