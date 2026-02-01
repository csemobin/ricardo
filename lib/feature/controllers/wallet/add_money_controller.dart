import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/view/wallet/payment_web_view_screen.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class AddMoneyController extends GetxController{
  final TextEditingController addMoneyTEController = TextEditingController();
  final GlobalKey<FormState> addMoneyFormState = GlobalKey<FormState>();

  final RxBool isAddedMoneyStatus = false.obs;
  final RxBool isAmountValid = false.obs;

  @override
  void onInit(){
    super.onInit();
    addMoneyTEController.addListener((){
      _validAmount();
    });
  }

  void _validAmount(){
    final text = addMoneyTEController.text.trim();
    if( text.isEmpty ){
      isAmountValid.value = false;
      return;
    }

    final amount = int.parse(text);
    if( amount == null || amount <= 0 ){
      isAmountValid.value = false;
    }else{
      isAmountValid.value = true;
    }
  }

  Future<void>addedAmount() async{
    if( !isAmountValid.value ) return;

    try{
      isAddedMoneyStatus.value = true;
      isAddedMoneyStatus.value = false;

      final amount = {
        "amount": addMoneyTEController.text.trim()
      };

      final response = await ApiClient.postData(ApiUrls.addBalance, amount);

      if( response.statusCode == 200 || response.statusCode == 201 ){
        cleanField();
        final paymentUrl = response.body['data']['paymentUrl'];
        await Get.to(()=> PaymentWebViewScreen(paymentUrl: paymentUrl));

      }else{
        Get.snackbar('Error', response.body['message'],snackPosition: SnackPosition.BOTTOM);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      isAddedMoneyStatus.value = false;
    }
  }

  void cleanField(){
    addMoneyTEController.clear();
    isAmountValid.value = false;
  }

  @override
  void dispose(){
    super.dispose();
    addMoneyTEController.dispose();
  }
}