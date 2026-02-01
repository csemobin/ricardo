import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_country_list.dart';
import 'package:ricardo/feature/controllers/wallet/payment_method_controller.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class AddCardController extends GetxController{

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxString searchQuery = ''.obs;
  RxList<String> filteredCountries = AppCountryList.sortedCountries.obs;

  final TextEditingController bankNameTEController = TextEditingController();
  final TextEditingController accountHolderNameTEController = TextEditingController();
  final TextEditingController accountNumberTEController = TextEditingController();
  final TextEditingController bankCodeTEController = TextEditingController();
  final TextEditingController selectedCountry = TextEditingController();

  RxBool isCardAddStatus = false.obs;

  Future<void> addCardHandler() async{
    try{
    isCardAddStatus.value = true;

    final data = {
      "bankName": bankNameTEController.text.trim(),
      "accountName": accountHolderNameTEController.text.trim(),
      "accountNumber": accountNumberTEController.text.trim(),
      "bankCode": bankCodeTEController.text.trim(),
      "country": selectedCountry.text.trim(),
    };

    // final reqBody = jsonEncode(data);
    final response = await ApiClient.postData(ApiUrls.paymentCardStore, data);
    if( response.statusCode == 200 || response.statusCode == 201 ){
      Get.back();
      PaymentMethodController().fetchPaymentCardInfo();
    }else{
      Get.snackbar('Error', response.body['message'],snackPosition: SnackPosition.BOTTOM,backgroundColor: AppColors.errorColor);
    }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      isCardAddStatus.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    bankNameTEController.dispose();
    accountHolderNameTEController.dispose();
    accountNumberTEController.dispose();
    bankCodeTEController.dispose();
    selectedCountry.dispose();
  }
}