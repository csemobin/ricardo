import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class AddCardScreen extends StatelessWidget {
  AddCardScreen({super.key});

  final TextEditingController cardNameTEController = TextEditingController();
  final TextEditingController expireTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text('Add Card'),
        backgroundColor: AppColors.bgColor,
      ),
      body: Column(
        children: [
          CustomTextField(
            controller: cardNameTEController,
            labelText: 'Card Number',
            hintText: 'Enter Amount',
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Assets.images.visaPayment.path, // Use visa asset
                    height: 24,
                    width: 36,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    Assets.images.masterCardIcon.path,
                    height: 24,
                    width: 36,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: expireTEController,
                  hintText: 'DD-MM-YYYY',
                  labelText: 'Expire Date',
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                child: CustomTextField(
                  controller: expireTEController,
                  hintText: 'CVC',
                  labelText: 'CVC',
                ),
              )
            ],
          ),
          CustomTextField(
            controller: expireTEController,
            hintText: 'Select',
            labelText: 'Country',
            suffixIcon: Icon(
              (Icons.keyboard_arrow_down),
            ),
          ),
          Spacer(),
          CustomPrimaryButton(title: 'Add Button', onHandler: (){}),
          Spacer(),
        ],
      ),
    );
  }
}
