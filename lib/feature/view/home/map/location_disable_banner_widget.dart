import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

class LocationDisableBannerWidget extends StatelessWidget {
  const LocationDisableBannerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.red,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 25),
          bottom: true,
          left: true,
          child: Padding(
            padding: const EdgeInsets.only(
                top: 20, bottom: 20, left: 12, right: 12),
            child: Row(
              children: [
                const Icon(Icons.location_off,
                    color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Location is disabled. Enable to continue.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => LocationPermissionService
                      .openLocationSettings(),
                  child: const Text(
                    'ENABLE',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}