import 'package:flutter/cupertino.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
class PassengerInfoCard extends StatelessWidget {
  const PassengerInfoCard({
    super.key,
    required this.mapOPTController,
  });

  final MapOPTController mapOPTController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  (mapOPTController
                      .rideStatusData
                      .value
                      ?.passenger?.image?.filename !=
                      null &&
                      mapOPTController
                          .rideStatusData.value!.passenger!.image!.filename!.isNotEmpty )
                      ? '${ApiUrls.imageBaseUrl}${mapOPTController.rideStatusData.value?.passenger?.image?.filename}'
                      : '',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/default_image.jpg',
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  mapOPTController.rideStatusData.value
                      ?.passenger?.name ??
                      '',
                  style: TextStyle(
                    color: const Color(0xff171717),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.poppins,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '\$${mapOPTController.rideStatusData.value?.ride?.fare ?? 0.0} ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '(${((mapOPTController.rideStatusData.value?.ride?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} KM)',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse(
                "tel:${mapOPTController.rideStatusData.value?.passenger?.phone}"));
          },
          child: RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: AppColors.greyColor200,
                ),
              ),
              child: SvgPicture.asset(
                  Assets.icons.driverCardPhone),
            ),
          ),
        ),
      ],
    );
  }
}