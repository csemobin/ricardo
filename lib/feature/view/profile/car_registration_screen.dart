import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_image_uploader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/widgets.dart';

class CarRegistrationScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  CarRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: AppBar(
          backgroundColor: AppColors.bgColor,
          forceMaterialTransparency: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Car Registration',
                  style: AppCustomDesign.headingTextStyle,
                ),
              ),
              SizedBox(
                height: 37.h,
              ),


              CustomTextField(
                controller: nameController,
                labelText: 'Car Name',
                hintText: 'Enter  Car name',
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomTextField(
                controller: nameController,
                labelText: 'Car Plate No',
                hintText: 'Enter the number plate no. of your Car',
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomTextField(
                controller: nameController,
                labelText: 'Car Registration Date',
                hintText: 'DD- MM-YYYY',
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomTextField(
                controller: nameController,
                labelText: 'Number of seat',
                hintText: 'Enter the seat number',
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomImageUploader(
                label: 'Upload Your Car Picture',
                uploadedTitle: 'Upload files',
                fileSize: '25',
                buttonTitle: 'Browse Files',
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomImageUploader(
                label: 'Upload your Registration card picture ',
                uploadedTitle: 'Upload files',
                fileSize: '25',
                buttonTitle: 'Browse Files',
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomImageUploader(
                label: 'Upload a picture of your number plate',
                uploadedTitle: 'Upload files',
                fileSize: '25',
                buttonTitle: 'Browse Files',
              ),
              SizedBox(height: 38.h,),
              CustomPrimaryButton(title: 'Submit', onHandler: () {
                Get.toNamed(AppRoutes.profileCompletePopupModelScreen);
              }),
              SizedBox(height: 10.h,)
            ],
          ),
        ));
  }
}
