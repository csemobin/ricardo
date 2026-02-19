import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/map/report_controller.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController txController = TextEditingController();
  final controller = Get.put(ReportController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Report an Issue',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 24.h,
            ),
            Center(
              child: CustomHeadingText(
                firstText: 'What',
                secondText: 'happened?',
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Center(
              child: Text(
                'What\’s wrong with the rider',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: FontFamily.poppins,
                    color: AppColors.secondaryTextColor),
              ),
            ),
            SizedBox(
              height: 42.h,
            ),
            _buildRadioOption(1, 'Safety Issues'),
            _buildRadioOption(2, 'Behavior Issues'),
            _buildRadioOption(3, 'Trip Issues'),
            _buildRadioOption(4, 'Vehicle Issues'),
            _buildRadioOption(5, 'Other'),

            Obx(() {
              if (controller.radioBtnValue.value == 5) {
                return CustomTextField(
                  controller: txController,
                  labelText: 'Write Your Issue',
                  hintText: 'Add Note',
                  minLines: 5,
                );
              }
              return const SizedBox.shrink();
            }),

            SizedBox(
              height: 110.h,
            ),
            CustomPrimaryButton(title: 'Submit Report', onHandler: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(int value, String label) {
    return InkWell(
      onTap: () {
        controller.radioBtnValue.value = value;
      },
      child: Row(
        children: [
          Obx(() => Radio(
            value: value,
            groupValue: controller.radioBtnValue.value,
            onChanged: (value) {
              controller.radioBtnValue.value = value!;
            },
          )),
          SizedBox(width: 10.0),
          Text(label)
        ],
      ),
    );
  }
}
