import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/wallet/payment_card_info.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class PaymentMethodController extends GetxController{
  //Payment Card Info Status
  RxBool paymentCardInfoStatus = false.obs;
  RxList<PaymentCardInfoModel?> paymentCardInfo = <PaymentCardInfoModel>[].obs;

  Future<void> fetchPaymentCardInfo() async{
    try{
      paymentCardInfoStatus.value = true;
      final response = await ApiClient.getData(ApiUrls.paymentCardInfo);
      if( response.statusCode == 200 || response.statusCode == 201 ){
        final List datas = response.body['data'];
        paymentCardInfo.value =  datas.map((e)=> PaymentCardInfoModel.fromJson(e)).toList();
      }else{
        Get.snackbar('Error', response.body['data']['message']);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      paymentCardInfoStatus.value = false;
    }
  }

  // Delete Card Related work are here
  RxBool isCardDelete = false.obs;
  Future<bool> deletePaymentCard(String cardId) async {
    try {
      isCardDelete.value = true;
      final response = await ApiClient.deleteData(ApiUrls.paymentCardDelete(cardId));
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Remove the card from the list immediately
        paymentCardInfo.removeWhere((card) => card?.sId == cardId);

        Get.snackbar(
          'Success',
          'Your card is deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to delete card');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting card: $e');
      Get.snackbar('Error', 'Failed to delete card');
      return false;
    } finally {
      isCardDelete.value = false;
    }
  }
}