import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

import 'glass_background_multiple_widget.dart';

class AnimatedToggleSwitch extends StatefulWidget {
  const AnimatedToggleSwitch({super.key});

  @override
  State<AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<AnimatedToggleSwitch> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isOnline) {
          // Going OFFLINE - Show confirmation dialog
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return Dialog(
                elevation: 5,
                backgroundColor: Colors.transparent,
                child: GlassBackgroundWidget(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'X',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: Icon(
                        Icons.wifi_off,
                        size: 50.r,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Are you sure you would like to go Offline?',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Color(0xff171717),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isOnline = false;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            'Go Offline',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          // Going ONLINE - Just change state directly, NO dialog
          setState(() {
            isOnline = true;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 130,
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isOnline ? Colors.green : Colors.grey.shade700,
        ),
        child: Stack(
          children: [
            // Background text
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isOnline ? 16 : null,
              right: isOnline ? null : 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Animated circle with car icon
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment:
                  isOnline ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? Colors.white : Colors.grey.shade600,
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_car,
                    color: isOnline ? Colors.green : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
