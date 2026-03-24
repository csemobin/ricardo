import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/wallet/recent_history.dart';
import 'package:ricardo/feature/models/wallet/wallet_history_model.dart';
import 'package:ricardo/feature/view/wallet/wallet_screen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ricardo/app/utils/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar if needed
            print('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            print('Page finished loading: $url');

            // Check if payment is successful
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
            Get.snackbar(
              'Error',
              'Failed to load payment page',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation request: ${request.url}');

            // Handle success/cancel URLs
            if (request.url.contains('success') ||
                request.url.contains('payment_intent')) {
              _handlePaymentSuccess();
              // return NavigationDecision.prevent;
            }

            if (request.url.contains('cancel')) {
              _handlePaymentCancel();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    // Check if URL indicates successful payment
    if (url.contains('success') || url.contains('payment_intent_client_secret')) {
      _handlePaymentSuccess();
    } else if (url.contains('cancel')) {
      _handlePaymentCancel();
    }
  }

  void _handlePaymentSuccess() {

    final hstController = Get.find<RecentHistoryController>();
    hstController.forceRefresh();

    final controller = Get.find<CustomBottomNavBarController>();
    controller.selectedIndex.value = 1;
    Get.offAllNamed(AppRoutes.customBottomNavBar);
  }

  void _handlePaymentCancel() {
    Get.back(result: {'success': false});
    Get.snackbar(
      'Cancelled',
      'Payment was cancelled',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Balance',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w500
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close,color: AppColors.whiteColor,size: 24,),
          onPressed: () {
            _showExitDialog();
          },
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(result: {'success': false}); // Close WebView
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
}