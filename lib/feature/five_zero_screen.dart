import 'package:flutter/material.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class FiveZeroScreen extends StatefulWidget {
  const FiveZeroScreen({super.key});


  @override
  State<FiveZeroScreen> createState() => _FiveZeroScreenState();
}

class _FiveZeroScreenState extends State<FiveZeroScreen> {
  bool _isRetrying = false;

  Future<void> _retryConnection() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      final response = await ApiClient.getData(ApiUrls.imageBaseUrl);

      if (response.statusCode == 200) {
        _onServerOnline();
        return;
      }

      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
        _showMessage('Server is still down. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
        _showMessage('Connection failed. Please try again.');
      }
    }
  }

  void _onServerOnline() {
    _showMessage('Server is back online! Redirecting...', isSuccess: true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // PrefsHelper.remove(AppConstants.bearerToken);
        // PrefsHelper.clearAllDatas();
        // Get.offAllNamed(AppRoutes.loginScreen);
      }
    });
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Server icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),

                const SizedBox(height: 40),

                // Error code
                Text(
                  '502',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey.shade800,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 8),

                // Error message
                Text(
                  'Server Unavailable',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'We\'re experiencing technical difficulties.\nPlease try again in a moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 48),

                // Retry button or loading
                if (_isRetrying)
                  Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Checking server status...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton(
                    onPressed: _retryConnection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 48),

                // Divider
                Container(
                  width: 60,
                  height: 1,
                  color: Colors.grey.shade300,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}