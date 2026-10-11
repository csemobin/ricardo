import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final RxBool isConnected = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _check();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _check());
  }

  Future<bool> _check() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      final connected =
          result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      isConnected.value = connected;
      return connected;
    } catch (_) {
      isConnected.value = false;
      return false;
    }
  }

  Future<bool> recheck() => _check();

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
