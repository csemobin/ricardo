import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_text.dart';
import '../utils/app_colors.dart';

class PhotoPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static void showPicker({
    required BuildContext context,
    required Function(XFile file) onImagePicked,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(text:
                'Select Photo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
               SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    source: ImageSource.camera,
                    onImagePicked: onImagePicked,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    source: ImageSource.gallery,
                    onImagePicked: onImagePicked,
                  ),
                ],
              ),
             // const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required ImageSource source,
        required Function(XFile file) onImagePicked,
      }) {
    return InkWell(
      onTap: () async {
        final XFile? file = await _picker.pickImage(source: source);
        Navigator.pop(context);
        if (file != null) onImagePicked(file);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            padding:  EdgeInsets.all(16.r),
            child: Icon(icon, size: 30.r, color: AppColors.secondaryColor),
          ),
           SizedBox(height: 8.h),
          CustomText(text:
            label,
              color: AppColors.darkColor,
            ),
        ],
      ),
    );
  }
}
