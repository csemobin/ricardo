import 'package:flutter/material.dart';
import 'package:ricardo/feature/models/wallet/withdraw_settings_model.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/services/api_client.dart';

class AppSettingsController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<WithdrawSettingsModel?> settings = Rx<WithdrawSettingsModel?>(null);

  double get perMilePrice => settings.value?.perMilePrice ?? 1;
  double get waitingTimeCharge => settings.value?.waitingTimeCharge ?? 0;
  double get cancellationFeePerMile =>
      settings.value?.cancellationFeePerMile ?? 0;
  double get platformFeePercentage =>
      settings.value?.platformFeePercentage ?? 0;
  double get minimumWithdrawAmount =>
      settings.value?.minimumWithdrawAmount ?? 0;
  bool get isWithdrawDisabled => settings.value?.isWithdrawEnabled == true;
  List<String> get freeWithdrawDays =>
      settings.value?.freeWithdrawDays ?? [];

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await tokenData();

    if (token != null && token.isNotEmpty) {
      await fetchSettings();
    }
  }

  Future<String?> tokenData() async {
    return PrefsHelper.getString(AppConstants.bearerToken);
  }

  Future<void> fetchSettings() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final response = await ApiClient.getData(ApiUrls.withdrawSettings);
      if (response.statusCode == 200 && response.body['data'] != null) {
        settings.value =
            WithdrawSettingsModel.fromJson(response.body['data']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
