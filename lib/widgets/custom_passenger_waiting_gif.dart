import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

class CustomPassengerWaitingGif extends StatelessWidget {
  const CustomPassengerWaitingGif({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(Assets.lotties.timer, fit: BoxFit.cover),
        Text(
          'Waiting for Passenger request...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: FontFamily.poppins,
            color: AppColors.primaryColor,
          ),
          textAlign: TextAlign.center, // ✅ এটাই যথেষ্ট
        ),
      ],
    );
  }
}
