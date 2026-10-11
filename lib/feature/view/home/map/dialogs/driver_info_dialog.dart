import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

void showDriverInfoDialog(
  BuildContext context,
  dynamic driver,
  RideController rideController,
) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkColor.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    driver.image != null && driver.image!.isNotEmpty
                        ? ClipRRect(
                            clipBehavior: Clip.antiAlias,
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              '${ApiUrls.imageBaseUrl}${driver.image}',
                              fit: BoxFit.cover,
                              height: 60,
                              width: 60,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                      'assets/images/default_image.jpg',
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover),
                            ),
                          )
                        : CircleAvatar(
                            radius: 30,
                            child: Image.asset(
                                'assets/images/default_image.jpg',
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover),
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${driver.name}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                  '${driver.rating} (${driver.totalRatings})'),
                              const SizedBox(width: 8),
                              const Text('|'),
                              const SizedBox(width: 8),
                              Text('${driver.trips} Trips'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text('${driver.phone}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse("tel:${driver.phone}"));
                      },
                      child: RepaintBoundary(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: SvgPicture.asset(
                            Assets.icons.driverCardPhone,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Align(
                  alignment: Alignment.center,
                  child: Text('Car Info.',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${driver.vehicle?.carName}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${driver.vehicle?.numberOfSeat} Seat'),
                          const SizedBox(height: 4),
                          Text('${driver.vehicle?.carPlateNumber}'),
                          const SizedBox(height: 4),
                          FutureBuilder<String>(
                            future: DirectionsService.calculateDistance(
                              driver.location?.coordinates?[0],
                              driver.location?.coordinates?[1],
                            ),
                            builder: (context, snapshot) {
                              final distanceText =
                                  snapshot.data ?? 'Calculating...';
                              return Text(
                                '$distanceText away from you.',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 16.sp,
                                  color: AppColors.dottedBorderColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: driver.image != null && driver.image!.isNotEmpty
                          ? Image.network(
                              '${ApiUrls.imageBaseUrl}${driver.image}',
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                      'assets/images/default_image.jpg',
                                      width: 92,
                                      height: 92,
                                      fit: BoxFit.cover),
                            )
                          : Image.asset('assets/images/default_image.jpg',
                              width: 92, height: 92, fit: BoxFit.cover),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RequestRideHandler(
                  cnt: rideController,
                  cardDetails: driver,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
