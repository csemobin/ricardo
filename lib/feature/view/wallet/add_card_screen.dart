import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/wallet/add_card_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final controller = Get.put(AddCardController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text('Add Card'),
        backgroundColor: AppColors.bgColor,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: controller.bankNameTEController,
                labelText: 'Bank Name',
                hintText: 'Please Enter your Bank Name',
              ),
              CustomTextField(
                controller: controller.accountHolderNameTEController,
                labelText: 'Account Holder Name',
                hintText: 'Please Enter Account Holder Name',
              ),
              CustomTextField(
                controller: controller.accountNumberTEController,
                labelText: 'Account Number',
                hintText: 'Enter Amount Number',
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
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                keyboardType: TextInputType.number,
              ),
              CustomTextField(
                controller: controller.bankCodeTEController,
                labelText: 'Bank Code',
                hintText: 'Enter Your Bank Code',
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                keyboardType: TextInputType.number,
              ),
              CustomTextField(
                controller: controller.selectedCountry,
                hintText: 'Please Select Country',
                labelText: 'Country',
                readOnly: true,
                suffixIcon: Icon(Icons.keyboard_arrow_down),
                onTap: () {
                  controller.searchQuery.value = '';
                  _showCountryBottomSheet(context);
                },
              ),
              CustomTextField(
                controller: controller.moreInfoTEController,
                minLines: 5,
                hintText: 'If Additional Information',
                labelText: 'Added Additional Information ( Optional )',
                validator: (val){},
              ),
              SizedBox(
                height: 40.h,
              ),
              Obx(() {
                return CustomPrimaryButton(
                  title: controller.isCardAddStatus.value == true
                      ? 'Card Added...'
                      : 'Add Card',
                  onHandler: isSubmit,
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  void isSubmit() {
    if (controller.formKey.currentState!.validate()) {
      controller.addCardHandler();
    } else {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showCountryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Country',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  Expanded(
                    child: controller.filteredCountries.isEmpty
                        ? Center(
                            child: Text(
                              'No countries found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: controller.filteredCountries.length,
                            itemBuilder: (context, index) {
                              final country =
                                  controller.filteredCountries[index];
                              return ListTile(
                                title: Text(country),
                                onTap: () {
                                  controller.selectedCountry.text = country;
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
