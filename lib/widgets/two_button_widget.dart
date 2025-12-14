import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/widgets.dart';
import '../app/utils/app_colors.dart';

class TwoButtonWidget extends StatelessWidget {
  final List<Map<String, String>> buttons;
  final String selectedValue;
  final Function(String) onTap;
  final double? fontSize;

  const TwoButtonWidget({
    super.key,
    required this.buttons,
    required this.selectedValue,
    required this.onTap,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons.map((item) {
        final isSelected = item['value'] == selectedValue;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(item['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondaryColor : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.secondaryColor,
                    width: 2,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: CustomText(
                  text: item['label']!,
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: fontSize ?? 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
