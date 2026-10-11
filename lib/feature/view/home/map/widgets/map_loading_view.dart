import 'package:flutter/material.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class MapLoadingView extends StatelessWidget {
  const MapLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 20),
          Text('Loading map...'),
        ],
      ),
    );
  }
}
