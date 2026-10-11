import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

void showLocationPermissionDeniedDialog(
  BuildContext context, {
  required VoidCallback onRetry,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Location Permission Required'),
      content: const Text(
        'This app needs location access to show your position on the map and find nearby rides.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onRetry();
          },
          child: const Text('Retry'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

void showLocationPermissionPermanentlyDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Location Permission Required'),
      content: const Text(
        'Location permission is permanently denied. Please enable it in settings to use this app.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Geolocator.openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}
