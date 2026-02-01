import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/wallet/add_money_controller.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class AddAmountScreen extends StatefulWidget {
  const AddAmountScreen({super.key});

  @override
  State<AddAmountScreen> createState() => _AddAmountState();
}

class _AddAmountState extends State<AddAmountScreen> {
  final controller = Get.put(AddMoneyController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
        title: Text(
          'Add Amount',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: controller.addMoneyFormState,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              CustomTextField(
                labelText: 'Added Amount',
                controller: controller.addMoneyTEController,
                keyboardType: TextInputType.number,
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                hintText: "Enter Your Amount",
              ),
              SizedBox(
                height: 10.h,
              ),
              Obx(
                () {
                  return CustomPrimaryButton(
                    title: controller.isAddedMoneyStatus.value
                        ? 'Adding...'
                        : 'Add Money',
                    onHandler: controller.isAmountValid.value
                        ? () {
                            FocusScope.of(context).unfocus();
                            controller.isAddedMoneyStatus.value = false;
                            controller.addedAmount();
                        }
                        : null,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
