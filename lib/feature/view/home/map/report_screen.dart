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
  // final TextEditingController txController = TextEditingController();
  final rideId = Get.arguments['rideId'];

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
              height: 18.h,
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
              height: 28.h,
            ),
            _buildRadioOption(1, 'Safety Issues'),
            _buildRadioOption(2, 'Behavior Issues'),
            _buildRadioOption(3, 'Trip Issues'),
            _buildRadioOption(4, 'Vehicle Issues'),
            _buildRadioOption(5, 'Other'),
            Obx(() {
              if (controller.radioBtnValue.value == 5) {
                return CustomTextField(
                  controller: controller.txController,
                  labelText: 'Write Your Issue',
                  hintText: 'Add Note',
                  minLines: 5,
                );
              }
              return const SizedBox.shrink();
            }),
            SizedBox(
              height: 36.h,
            ),
            Obx(() {
              final loading = controller.isReportStatus.value;
              return CustomPrimaryButton(
                title: 'Submit Report',
                isLoading: loading,
                onHandler: loading
                    ? null
                    : () => _reportButtonHandler(rideId),
              );
            }),
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
          Obx(() => Radio<int>(
                value: value,
                groupValue: controller.radioBtnValue.value,
                activeColor: const Color(0xff007635),
                onChanged: (value) {
                  controller.radioBtnValue.value = value!;
                },
              )),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
          )
        ],
      ),
    );
  }

  // reportButtonHandler already surfaces the specific failure reason.
  void _reportButtonHandler(String rideId) async {
    final value = await controller.reportButtonHandler(rideId);
    if (value == true) {
      Get.back();
    }
  }
}
