import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHandler {
  ///=====>>>>>> Image Related work are here =====>>>>>> ////
  static final _imagePicker = ImagePicker();

  // Camera Image Picker Related work
  static Future<XFile?> cameraImagePicker() async {
    return await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxHeight: 800,
      maxWidth: 800,
    );
  }

  // Media Upload Image Picker Related work
  static Future<XFile?> galleryImagePicker() async {
    return await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.front,
      requestFullMetadata: true,
    );
  }

  static void bottomImageSelector(
      BuildContext context, {
        Color? backgroundColor,
        double? height,
        double? borderRadius,
        double? spacing,
        EdgeInsets? padding,
        MainAxisAlignment? alignment,
        bool showCamera = true,
        String? cameraLabel,
        IconData? cameraIcon,
        String? cameraImagePath,
        double? cameraIconSize,
        Color? cameraIconColor,
        TextStyle? cameraTextStyle,
        bool showGallery = true,
        String? galleryLabel,
        IconData? galleryIcon,
        String? galleryImagePath,
        double? galleryIconSize,
        Color? galleryIconColor,
        TextStyle? galleryTextStyle,
        double? iconSize,
        Color? iconColor,
        TextStyle? textStyle,
        double? spaceBetweenIconAndText,
        required Function(XFile file) onImageSelected,
      }) {
    showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      backgroundColor: backgroundColor ?? Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius ?? 20),
        ),
      ),
      builder: (context) {
        return Container(
          height: height ?? 160,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: alignment ?? MainAxisAlignment.spaceEvenly,
            children: [
              // Camera option
              if (showCamera)
                GestureDetector(
                  onTap: () async {
                    final image = await cameraImagePicker();
                    if (image != null) {
                      onImageSelected(image);
                    }
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show custom image or icon for camera
                      if (cameraImagePath != null)
                        Image.asset(
                          cameraImagePath,
                          width: cameraIconSize ?? iconSize ?? 40,
                          height: cameraIconSize ?? iconSize ?? 40,
                          fit: BoxFit.cover,
                        )
                      else
                        Icon(
                          cameraIcon ?? Icons.camera_alt,
                          size: cameraIconSize ?? iconSize ?? 40,
                          color: cameraIconColor ?? iconColor,
                        ),
                      SizedBox(height: spaceBetweenIconAndText ?? 8),
                      Text(
                        cameraLabel ?? "Camera",
                        style: cameraTextStyle ?? textStyle,
                      ),
                    ],
                  ),
                ),

              // Spacing between options
              if (showCamera && showGallery)
                SizedBox(width: spacing ?? 0),

              // Gallery option
              if (showGallery)
                GestureDetector(
                  onTap: () async {
                    final image = await galleryImagePicker();
                    if (image != null) {
                      onImageSelected(image);
                    }
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show custom image or icon for gallery
                      if (galleryImagePath != null)
                        Image.asset(
                          galleryImagePath,
                          width: galleryIconSize ?? iconSize ?? 40,
                          height: galleryIconSize ?? iconSize ?? 40,
                          fit: BoxFit.cover,
                        )
                      else
                        Icon(
                          galleryIcon ?? Icons.photo_library,
                          size: galleryIconSize ?? iconSize ?? 40,
                          color: galleryIconColor ?? iconColor,
                        ),
                      SizedBox(height: spaceBetweenIconAndText ?? 8),
                      Text(
                        galleryLabel ?? "Gallery",
                        style: galleryTextStyle ?? textStyle,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}