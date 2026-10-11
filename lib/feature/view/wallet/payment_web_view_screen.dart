import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:ricardo/app/helpers/snackbar_helper.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/wallet/recent_history.dart';
import 'package:ricardo/routes/app_routes.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;

  bool isLoading = true;
  bool _paymentHandled = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('Loading: $progress%');
          },

          onPageStarted: (String url) {
            debugPrint('Page Started: $url');

            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
          },

          onPageFinished: (String url) {
            debugPrint('Page Finished: $url');

            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },

          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation URL: ${request.url}');

            /// SUCCESS URL
            if (request.url.contains('payment-success') ||
                request.url.contains('success')) {
              _handlePaymentSuccess();

              return NavigationDecision.prevent;
            }

            /// CANCEL URL
            if (request.url.contains('cancel')) {
              _handlePaymentCancel();

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          onWebResourceError: (WebResourceError error) {
            debugPrint('========== WEBVIEW ERROR ==========');
            debugPrint('URL: ${error.url}');
            debugPrint('Code: ${error.errorCode}');
            debugPrint('Description: ${error.description}');
            debugPrint('Type: ${error.errorType}');
            debugPrint('===================================');

            final url = error.url ?? '';

            /// Ignore localhost success redirect errors
            if (url.contains('localhost:8080/payment-success')) {
              return;
            }

            /// Ignore errors after success already handled
            if (_paymentHandled) {
              return;
            }

            showSnackbar(
              'Error',
              'Failed to load payment page',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _handlePaymentSuccess() async {
    if (_paymentHandled) return;

    _paymentHandled = true;

    debugPrint('PAYMENT SUCCESS');

    try {
      final historyController = Get.find<RecentHistoryController>();

      await historyController.forceRefresh();
    } catch (e) {
      debugPrint('History refresh error: $e');
    }

    try {
      final navController =
      Get.find<CustomBottomNavBarController>();

      navController.selectedIndex.value = 1;
    } catch (e) {
      debugPrint('Bottom nav error: $e');
    }

    showSnackbar(
      'Success',
      'Balance added successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      Get.offAllNamed(AppRoutes.customBottomNavBar);
    });
  }

  void _handlePaymentCancel() {
    if (_paymentHandled) return;

    _paymentHandled = true;

    showSnackbar(
      'Cancelled',
      'Payment was cancelled',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );

    Get.back(result: {'success': false});
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel this payment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _handlePaymentCancel();
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: const Text(
          'Add Balance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: _showExitDialog,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}