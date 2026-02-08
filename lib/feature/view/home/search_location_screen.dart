import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text(
          "Let's Go...",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.poppins,
          ),
        ),
        forceMaterialTransparency: true,
        backgroundColor: AppColors.bgColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 27.h,
          ),
          CustomTextField(
            controller: controller,
            labelText: 'Set Pick-up Location',
            prefixIcon: Image.asset(Assets.images.greenPin.path),
            hintText: 'Enter Pick-up Location',
          ),
          CustomTextField(
            controller: controller,
            labelText: 'Set Drop-off Location',
            prefixIcon: Image.asset(Assets.images.greenPin.path),
            hintText: 'Enter Drop-off location',
          ),
          CustomTextField(
            minLines: 5,
            controller: controller,
            hintText: 'Add Note',
            labelText: 'Add Note for Driver (optional)',
          ),
          SizedBox(height: 65,),
          CustomPrimaryButton(
            onHandler: () {},
            title: 'Find Ride',
          )
        ],
      ),
    );
  }
}
