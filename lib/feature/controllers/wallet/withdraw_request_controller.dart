import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/controllers/wallet/recent_history.dart';
import 'package:ricardo/feature/models/wallet/payment_card_info.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class WithdrawRequestController extends GetxController {
  RxBool isWithdrawRequestStatus = false.obs;

  final TextEditingController amountTEController = TextEditingController();

  /// Selected card
  Rx<PaymentCardInfoModel?> selectedCard =
  Rx<PaymentCardInfoModel?>(null);

  /// Form validation
  RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    amountTEController.addListener(_validateForm);
  }

  void selectCard(PaymentCardInfoModel card) {
    selectedCard.value = card;
    _validateForm();
  }

  void _validateForm() {
    final amountText = amountTEController.text.trim();
    final amount = int.tryParse(amountText) ?? 0;

    isFormValid.value =
        amount > 0 && selectedCard.value != null;
  }

  Future<void> withdrawRequestHandler() async {
    if (!isFormValid.value) return;

    try {
      isWithdrawRequestStatus.value = true;

      final card = selectedCard.value!;
      final amount = double.tryParse(amountTEController.text.trim()) ?? 0;

      final reqBody = {
        "amount": amount,
        "bankName": card.bankName,
        "accountName": card.accountName,
        "accountNumber": card.accountNumber,
        "country": card.country,
        "bankCode": card.bankCode,
        "moreInfo": card.moreInfo,
      };

      final response = await ApiClient.postData(
        ApiUrls.withdrawRequest,
        reqBody,
      );
      if( response.statusCode == 200 || response.statusCode == 201 ){
        clearField();
        selectedCard.value = null;

        final cnt = Get.find<RecentHistoryController>();
        cnt.fetchRecentHistory(isLoadMore: false);

        final cntTwo = Get.find<CustomBottomNavBarController>();
        cntTwo.selectedIndex(1);

        Get.offAllNamed(AppRoutes.customBottomNavBar);

      }else{
        Get.snackbar('Error', response.body['data']['message'],snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isWithdrawRequestStatus.value = false;
    }
  }

  void clearField(){
    amountTEController.clear();
  }

  @override
  void onClose() {
    amountTEController.dispose();
    super.onClose();
  }
}
