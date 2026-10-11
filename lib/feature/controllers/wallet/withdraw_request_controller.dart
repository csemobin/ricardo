import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/app_settings_controller.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/wallet/recent_history.dart';
import 'package:ricardo/feature/models/wallet/payment_card_info.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class WithdrawRequestController extends GetxController {
  final controller = Get.find<RecentHistoryController>();
  final appSettings = Get.find<AppSettingsController>();

  RxBool isWithdrawRequestStatus = false.obs;

  final TextEditingController amountTEController = TextEditingController();

  Rx<PaymentCardInfoModel?> selectedCard = Rx<PaymentCardInfoModel?>(null);

  RxBool isFormValid = false.obs;
  RxBool isFormValidAmount = true.obs;
  RxBool isMinimumAmountValid = true.obs;

  bool get isWithdrawDisabled => appSettings.isWithdrawDisabled;

  bool get isTodayFreeWithdrawDay {
    final days = appSettings.freeWithdrawDays;
    if (days.isEmpty) return false;
    final today = DateFormat('EEEE').format(DateTime.now()).toUpperCase();
    return days.contains(today);
  }

  double get platformFeePercentage => appSettings.platformFeePercentage;

  double get minimumWithdrawAmount => appSettings.minimumWithdrawAmount;

  String get formattedFreeWithdrawDays {
    final days = appSettings.freeWithdrawDays;
    if (days.isEmpty) return '';
    return days.map(_formatDayName).join(', ');
  }

  String _formatDayName(String day) {
    if (day.isEmpty) return day;
    final lower = day.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  void onInit() {
    super.onInit();
    amountTEController.addListener(_validateForm);
    ever(appSettings.settings, (_) => _validateForm());
    if (appSettings.settings.value == null) {
      appSettings.fetchSettings();
    } else {
      _validateForm();
    }
  }

  void selectCard(PaymentCardInfoModel card) {
    selectedCard.value = card;
    _validateForm();
  }

  void _validateForm() {
    final amountText = amountTEController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    final minAmount = minimumWithdrawAmount;

    isFormValidAmount.value = controller.userWallet >= amount;
    isMinimumAmountValid.value = amount >= minAmount;

    isFormValid.value = !isWithdrawDisabled &&
        amount > 0 &&
        selectedCard.value != null &&
        isFormValidAmount.value &&
        isMinimumAmountValid.value;
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        clearField();
        selectedCard.value = null;

        final cnt = Get.find<RecentHistoryController>();
        cnt.fetchIfNeeded();

        final cntTwo = Get.find<CustomBottomNavBarController>();
        cntTwo.selectedIndex(1);

        Get.offAllNamed(AppRoutes.customBottomNavBar);
      } else {
        final errorMessage = response.body['message']?.toString();
        if (errorMessage != null &&
            errorMessage.isNotEmpty &&
            Get.context != null) {
          ScaffoldMessenger.of(Get.context!)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColors.errorColor,
              ),
            );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isWithdrawRequestStatus.value = false;
    }
  }

  void clearField() {
    amountTEController.clear();
  }

  @override
  void onClose() {
    amountTEController.dispose();
    super.onClose();
  }
}
