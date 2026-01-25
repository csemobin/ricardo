import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/auth/profile_update_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_image_uploader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserController userController = Get.find<UserController>();
  late final ProfileUpdateController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileUpdateController());
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: TextStyle(color: AppColors.primaryHeadingTextColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, containers) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: containers.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: profileController.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Center(
                        child: Stack(
                          children: [
                            // Add a default placeholder image
                            Center(
                              child: Stack(
                                children: [
                                  // Profile Image
                                  Obx(() {
                                    final user = userController.userModel.value;
                                    final imagePath = user?.userProfile?.image?.filename;

                                    return CircleAvatar(
                                      radius: 61.w, // Slightly larger than 122/2 for better fit
                                      backgroundColor: AppColors.greyColor300,
                                      child: imagePath != null
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: Image.network(
                                          '${ApiUrls.imageBaseUrl}$imagePath',
                                          width: 122.w,
                                          height: 122.h,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 60.w,
                                              color: Colors.white,
                                            );
                                          },
                                        ),
                                      )
                                          : Icon(
                                        Icons.person,
                                        size: 60.w,
                                        color: Colors.white,
                                      ),
                                    );
                                  }),

                                  // Edit Pencil Icon
                                  Positioned(
                                    bottom: 10.h,
                                    right: 15.h,
                                    child: Container(
                                      width: 35.w,
                                      height: 35.h,
                                      decoration: BoxDecoration(
                                        color: Color(0XffEDEDED),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        size: 18.w,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(controller: profileController.nameTEController,labelText: 'Name',),
                      SizedBox(height: 15.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Phone Number Field
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontFamily: FontFamily.poppins,
                                color: AppColors.labelTextColor,
                                fontSize: 12.h,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Obx(() {
                              final user = userController.userModel.value;
                              return IntlPhoneField(
                                flagsButtonPadding: EdgeInsets.only(left: 10),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (phone) {
                                  if (phone == null || phone.number.isEmpty) {
                                    return "Please enter your phone number";
                                  }
                                  if (!phone.isValidNumber()) {
                                    return "Please enter a valid phone number";
                                  }
                                  return null;
                                },
                                controller: profileController.phoneTEController,
                                // initialValue: user?.phone ?? '',
                                initialCountryCode: 'BD',
                                onChanged: (phone) {
                                  // Handle phone change
                                },
                                disableLengthCheck: false,
                                dropdownIconPosition: IconPosition.trailing,
                                dropdownTextStyle: TextStyle(
                                  color: AppColors.greyColor500,
                                  fontSize: 14.sp,
                                ),
                                style: TextStyle(
                                  color: AppColors.greyColor500,
                                  fontSize: 14.sp,
                                ),
                                decoration: InputDecoration(
                                  fillColor: AppColors.whiteColor,
                                  filled: true,
                                  hintText: 'Phone number',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 0.8.w,
                                      color: AppColors.grayShade100,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                  // ... other border styles
                                ),
                              );
                            }),

                            SizedBox(height: 10.h),

                            // Date of Birth Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date of Birth',
                                  style: TextStyle(
                                    fontFamily: FontFamily.poppins,
                                    color: AppColors.labelTextColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                // Obx(() {
                                //   return TextFormField(
                                //     validator: (val) {
                                //       if (val == null || val.isEmpty) {
                                //         return "Please select your date of birth";
                                //       }
                                //       try {
                                //         DateFormat('dd-MM-yyyy').parseStrict(val);
                                //         return null;
                                //       } catch (e) {
                                //         return "Please use DD-MM-YYYY format";
                                //       }
                                //     },
                                //     style: TextStyle(
                                //       color: AppColors.greyColor500,
                                //       fontSize: 12.sp,
                                //     ),
                                //     cursorColor: AppColors.appGreyColor,
                                //     // controller: profileController.dobTEController,
                                //     readOnly: true,
                                //     decoration: InputDecoration(
                                //       fillColor: AppColors.whiteColor,
                                //       filled: true,
                                //       hintText: 'DD-MM-YYYY',
                                //       hintStyle: TextStyle(
                                //         color: AppColors.greyColor,
                                //         fontSize: 12.sp,
                                //       ),
                                //       suffixIcon: IconButton(
                                //         icon: Icon(Icons.calendar_today),
                                //         onPressed: () async {
                                //           DateTime? pickedDate = await showDatePicker(
                                //             context: context,
                                //             firstDate: DateTime(1950),
                                //             lastDate: DateTime.now(),
                                //             initialDate: DateTime.now(),
                                //           );
                                //           if (pickedDate != null) {
                                //             String formattedData =
                                //                 "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                //             profileController.dobTEController.text = formattedData;
                                //           }
                                //         },
                                //       ),
                                //       border: OutlineInputBorder(
                                //         borderSide: BorderSide(
                                //           width: 0.8.w,
                                //           color: AppColors.grayShade100,
                                //         ),
                                //         borderRadius: BorderRadius.all(Radius.circular(8)),
                                //       ),
                                //       // ... other border styles
                                //     ),
                                //   );
                                // }),
                              ],
                            ),

                            SizedBox(height: 10.h),

                            // About Me Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About Me',
                                  style: TextStyle(
                                    fontFamily: FontFamily.poppins,
                                    color: AppColors.labelTextColor,
                                    fontSize: 12.h,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                // Obx(() {
                                //   return Stack(
                                //     children: [
                                //       TextFormField(
                                //         validator: (String? value) {
                                //           if (value == null || value.trim().isEmpty) {
                                //             return 'Please enter about yourself';
                                //           }
                                //           int words = value
                                //               .trim()
                                //               .split(RegExp(r'\s+'))
                                //               .where((word) => word.isNotEmpty)
                                //               .length;
                                //           if (words > 200) {
                                //             return 'Maximum 200 words allowed';
                                //           }
                                //           return null;
                                //         },
                                //         controller: profileController.aboutTEController,
                                //         minLines: 5,
                                //         maxLines: 5,
                                //         onChanged: (value) {
                                //           // Handle text change
                                //         },
                                //         decoration: InputDecoration(
                                //           hintText: 'Tell us about yourself...',
                                //           hintStyle: TextStyle(
                                //             color: AppColors.greyColor,
                                //             fontSize: 12.sp,
                                //             fontWeight: FontWeight.w400,
                                //           ),
                                //           contentPadding: EdgeInsets.all(12),
                                //           filled: true,
                                //           fillColor: AppColors.whiteColor,
                                //           border: OutlineInputBorder(
                                //             borderSide: BorderSide(
                                //               width: 0.8.w,
                                //               color: AppColors.grayShade100,
                                //             ),
                                //             borderRadius: BorderRadius.all(Radius.circular(8)),
                                //           ),
                                //           // ... other border styles
                                //         ),
                                //       ),
                                //       // Word count indicator
                                //       Positioned(
                                //         bottom: 10.r,
                                //         right: 10.r,
                                //         child: Obx(() {
                                //           final text = profileController.aboutTEController.text;
                                //           final wordCount = text
                                //               .trim()
                                //               .split(RegExp(r'\s+'))
                                //               .where((word) => word.isNotEmpty)
                                //               .length;
                                //           return Text(
                                //             '$wordCount/200 words',
                                //             style: TextStyle(
                                //               color: wordCount > 200 ? Colors.red : AppColors.greyColor500,
                                //               fontSize: 12.sp,
                                //             ),
                                //           );
                                //         }),
                                //       ),
                                //     ],
                                //   );
                                // }),
                              ],
                            ),

                            SizedBox(height: 40.h),

                            // Update Button
                            // Obx(() {
                            //   return CustomPrimaryButton(
                            //     title: 'Update Profile',
                            //     onHandler: () {
                            //       // if (profileController.formKey.currentState!.validate()) {
                            //       //   // Call update profile function
                            //       //   profileController.updateProfile();
                            //       // }
                            //     },
                            //   );
                            // }),

                            SizedBox(height: 10.h),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
