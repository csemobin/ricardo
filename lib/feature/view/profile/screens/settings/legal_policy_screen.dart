import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/profile/legal_controller.dart';
import 'package:ricardo/feature/simmer/legal_content_simmer.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class LegalPolicyScreen extends StatefulWidget {
  const LegalPolicyScreen({super.key});

  @override
  State<LegalPolicyScreen> createState() => _LegalPolicyScreenState();
}

class _LegalPolicyScreenState extends State<LegalPolicyScreen> {
  final controller = Get.find<LegalController>();

  final route = Get.arguments['route'];
  final title = Get.arguments['title'];

  @override
  void initState() {
    super.initState();
    if (route == 'terms') {
      controller.fetchLegalData('setting/terms-conditions');
    } else if (route == 'privacy') {
      controller.fetchLegalData('setting/privacy-policy');
    } else {
      controller.fetchLegalData('setting/about-us');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primaryHeadingTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.whiteColor),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Obx(
            () {
              return controller.isLoading.value == true ? LegalContentSimmer()  : Text(controller.legalContent.value);
            },
          ),
        ),
      ),
    );
  }
}
