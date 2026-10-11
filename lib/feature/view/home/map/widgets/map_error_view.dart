import 'package:flutter/material.dart';

class MapErrorView extends StatelessWidget {
  const MapErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 50),
          const SizedBox(height: 20),
          Text(errorMessage.isNotEmpty
              ? errorMessage
              : 'Unable to get your location'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
