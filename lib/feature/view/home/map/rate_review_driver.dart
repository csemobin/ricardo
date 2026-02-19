import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/map/rate_review_controller.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class RateReviewDriver extends StatelessWidget {
  RateReviewDriver({super.key});

  final controller = Get.put(RateAndReviewController());
  final TextEditingController txController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Text(
            'Rate & Review Driver',
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
                height: 88.h,
              ),
              Center(
                child: CustomHeadingText(
                  firstText: 'Rate',
                  secondText: 'Your Driver',
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Center(
                child: Text(
                  'How was your ride with Driver ?',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: FontFamily.poppins,
                      color: AppColors.secondaryTextColor),
                ),
              ),
              SizedBox(
                height: 78.h,
              ),
              _buildRattingField(),
              SizedBox(
                height: 48.h,
              ),
              CustomTextField(
                controller: txController,
                labelText: 'Write your feedback (optional)',
                hintText: 'Add Note',
                minLines: 5,
              ),
              SizedBox(
                height: 110.h,
              ),
              GestureDetector(
                onTap: (){} ,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  height: 56.h,
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      color: Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Add to Favourite',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:  Colors.green,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 21.h,),
              CustomPrimaryButton(title: 'Submit Review', onHandler: () {}),
            ],
          ),
        ));
  }

  Widget _buildRattingField() {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (_) {},
          child: RatingBar.builder(
            glow: false,
            allowHalfRating: true,
            itemCount: 5,
            initialRating: controller.driverRating.value,
            itemBuilder: (context, index) {
              return Icon(Icons.star, color: Colors.amber);
            },
            onRatingUpdate: (double value) {
              controller.driverRating.value = value;
            },
          ),
        ),
        // Obx(() => Text(
        //   'Your Rating: ${controller.driverRating.value}',
        //   style: TextStyle(fontSize: 14.sp),
        // )),
        // SizedBox(height: 16.h),
        // ElevatedButton(
        //   onPressed: () => IconButton(onPressed: (){}, icon: Icon(Icons.arrow_circle_left)), // ✅ send to backend
        //   child: Text('Submit'),
        // ),
      ],
    );
  }
}
