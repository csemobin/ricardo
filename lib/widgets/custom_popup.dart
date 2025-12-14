import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/widgets.dart';

class CustomPopupMenu extends StatelessWidget {
  const CustomPopupMenu({
    super.key,
    required this.items,
    required this.onSelected, this.iconColor, this.icon,
  });

  final List<String> items;
  final Function(String)? onSelected;
  final Color? iconColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(icon ?? Icons.more_vert,color: iconColor ?? Colors.white,),
      //constraints: BoxConstraints(maxHeight: 200.h),
      color: Colors.white,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return items.map((String item) {
          return PopupMenuItem<String>(
            height: 32.h,
            value: item,
            child: CustomText(text: item, fontSize: 12.sp),
          );
        }).toList();
      },
    );
  }
}
