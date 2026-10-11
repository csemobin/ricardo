import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/feature/view/home/map/location_disable_banner_widget.dart';

class LocationStatusBanner extends StatelessWidget {
  const LocationStatusBanner({super.key});

  Stream<bool> _locationStatusStream() {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await Geolocator.isLocationServiceEnabled();
    }).asyncMap((event) => event);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _locationStatusStream(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return LocationDisableBannerWidget();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
