import 'package:flutter/material.dart';
import 'package:ricardo/gen/assets.gen.dart';

class DriverBottomSheet {
  //Static method — call it from anywhere
  static void show(BuildContext context) {
    showDialog(
      context: context,
      // backgroundColor: Colors.transparent,
      builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child:  _DriverBottomSheetContent()
      ),
    );
  }
}

// Separate private widget for the content
class _DriverBottomSheetContent extends StatelessWidget {
  const _DriverBottomSheetContent();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ───── Driver Info Row ─────

              Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage:  AssetImage(
                      'assets/images/driver.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rakibul Hasa.K',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text('4.5 (40)'),
                            SizedBox(width: 8),
                            Text('|'),
                            SizedBox(width: 8),
                            Text('253 Trips'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.phone, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text('+123 456 789'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.chat, color: Colors.white),
                  ),
                ],
              ),
      
              const Divider(height: 24),
      
              // ───── Car Info ─────
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Car info.', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suzuki Alto 800',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('4 Seat'),
                        SizedBox(height: 4),
                        Text('DHK METRO HA 64-8888'),
                        SizedBox(height: 4),
                        Text(
                          '1 km away from you.',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      Assets.images.favoriteRidesBookCar.path,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
      
              const SizedBox(height: 16),
      
              // ───── Request Ride Button ─────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Request Ride',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
