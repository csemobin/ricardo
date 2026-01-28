import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/wallet/payment_card_info.dart';
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
      final reqBody = {
        "amount": amountTEController.text.trim(),
        "bankName": card.bankName,
        "accountName": card.accountName,
        "accountNumber": card.accountNumber,
        "country": card.country,
        "bankCode": card.routingNumber,
        "moreInfo": "I have swift code",
      };

      print("REQUEST BODY => $reqBody");

      // final response = await ApiClient.postData(
      //   ApiUrls.withdrawRequest,
      //   reqBody,
      // );

    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isWithdrawRequestStatus.value = false;
    }
  }

  @override
  void onClose() {
    amountTEController.dispose();
    super.onClose();
  }
}
