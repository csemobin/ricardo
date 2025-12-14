import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/widgets/custom_button.dart';
import 'package:ricardo/widgets/custom_text.dart';

class MenuShowHelper {
  static final List<String> heightOptions = List.generate(100, (index) {
    return "${(index ~/ 12) + 4}'${(index % 12)}\" cm";
  });

  static final List<String> weightOptions = List.generate(66, (index) {
    return "${35 + index} kg";
  });

  static final List<String> genderOptions = ["Male", "Female"];
  static final List<String> subjects = [
    // Primary School
    "Bangla",
    "English",
    "Mathematics",
    "Bangladesh & Global Studies",
    "Science",
    "Religion & Moral Education",
    "ICT",
    "Physical Education & Health",
    "Arts & Crafts",

    // Secondary/SSC
    "Bangla 1st Paper",
    "Bangla 2nd Paper",
    "English 1st Paper",
    "English 2nd Paper",
    "General Mathematics",
    "Higher Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "General Science",
    "ICT",
    "Religion",
    "Agriculture Studies",
    "Home Science",
    "Accounting",
    "Finance & Banking",
    "Business Entrepreneurship",
    "Geography & Environment",
    "History of Bangladesh & World Civilization",
    "Civics & Citizenship",
    "Economics",
    "Home Economics",

    // HSC Science
    "Physics (HSC)",
    "Chemistry (HSC)",
    "Biology (HSC)",
    "Higher Mathematics (HSC)",
    "Statistics",
    "ICT (HSC)",

    // HSC Commerce
    "Accounting (HSC)",
    "Finance & Banking (HSC)",
    "Business Organization & Management",
    "Production Management & Marketing",

    // HSC Arts
    "Bangla (HSC)",
    "English (HSC)",
    "Civics & Good Governance",
    "Social Work",
    "Geography",
    "Logic",
    "History",
    "Islamic Studies",
    "Psychology",
    "Economics (HSC)",
  ];  /// Shows a popup menu at the tap position from TapDownDetails.
  /// Returns the selected value or null if none selected.
  static Future<String?> showCustomMenu({
    required BuildContext context,
    required TapDownDetails details,
    required List<String> options,
  }) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset tapPosition = details.globalPosition;

    return showMenu<String>(
      context: context,
      color: Colors.white,
      constraints: BoxConstraints(
        maxHeight: 200.h,
        minWidth: 120.w,
        maxWidth: 180.w,
      ),
      position: RelativeRect.fromRect(
        Rect.fromPoints(tapPosition, tapPosition),
        Offset.zero & overlay.size,
      ),
      items: options.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
          child: SizedBox(
            height: 28.h,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option,
                style: TextStyle(fontSize: 12.sp, color: Colors.black),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  static Future<List<String>?> showMultiSelectMenu({
    required BuildContext context,
    required TapDownDetails details,
    required List<String> options,
    List<String>? preSelectedItems,
  }) async {
    List<String> selectedItems = preSelectedItems ?? [];

    return await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
                child: Column(
                  children: [
                    /// Drag Handle
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
              
                    /// Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CustomText(
                        text: "Select Subjects",
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
              
                    SizedBox(height: 12.h),
                    Divider(height: 1.h, color: Colors.grey[200]),
              
                    /// List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (_, index) {
                          final item = options[index];
                          final isSelected = selectedItems.contains(item);
              
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedItems.remove(item);
                                } else {
                                  selectedItems.add(item);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 20.sp,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.grey[400],
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: CustomText(
                                      text: item,
                                      textAlign: TextAlign.start,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              
                    /// Bottom Button
                    Padding(
                      padding:  EdgeInsets.all(16.r),
                      child: CustomButton(
                        onPressed: () {
                          Navigator.pop(context, selectedItems);
                        },
                        label: selectedItems.isEmpty
                            ? "Done"
                            : "Done (${selectedItems.length})",
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


}
