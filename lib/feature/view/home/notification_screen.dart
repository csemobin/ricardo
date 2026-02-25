import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/time_format.dart';
import 'package:ricardo/feature/controllers/home/map/notification_controller.dart';
import 'package:ricardo/feature/simmer/notification_shimmer.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final controller = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    if (mounted) {
      controller.fetchNotificationData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        forceMaterialTransparency: true,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isNotificationLoading.value) {
          return const NotificationShimmer();
        }
        return ListView.separated(
          controller: controller.scrollController,
          itemCount: controller.notificationData.length +
              (controller.isLoadMoreNotification.value ? 1 : 0),
          itemBuilder: (context, index) {

            if (index < controller.notificationData.length) {
              final data = controller.notificationData[index];
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔔 Icon Container
                    Container(
                      height: 45.h,
                      width: 45.w,
                      decoration: BoxDecoration(
                        color: data.viewStatus == false
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: data.viewStatus == false
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    /// 📩 Text Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// Title + unread dot
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data.title ?? '',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              if (data.viewStatus == false)
                                Container(
                                  height: 8.h,
                                  width: 8.w,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 6.h),

                          /// Message
                          Text(
                            data.message ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 8.h),

                          /// Time (optional)
                          Text(
                            TimeFormatHelper.formatNotificationTime(data.createdAt) ?? '',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
          separatorBuilder: (_, __) => SizedBox(height: 5.h),
        );
      }),
    );
  }
}
