import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/wallet/payment_method_controller.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class AddCardController extends GetxController{
  final TextEditingController cardNumberTEController = TextEditingController();
  final TextEditingController expireDateTEController = TextEditingController();
  final TextEditingController cvcTEController = TextEditingController();
  final TextEditingController selectedCountry = TextEditingController();

  RxBool isCardAddStatus = false.obs;

  Future<void> addCardHandler() async{
    try{
    isCardAddStatus.value = true;
    final reqBody = {

    };
    final response = await ApiClient.postData(ApiUrls.support, reqBody);
    if( response.statusCode == 200 || response.statusCode == 201 ){
      PaymentMethodController().fetchPaymentCardInfo();
      Get.back();
    }else{
      Get.snackbar('Error', response.body['data']['message']);
    }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      isCardAddStatus.value = false;
    }
  }
}