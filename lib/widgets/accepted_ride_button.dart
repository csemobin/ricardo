import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';

class AcceptRideButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AcceptRideButton({super.key, required this.onPressed});

  @override
  State<AcceptRideButton> createState() => _AcceptRideButtonState();
}

class _AcceptRideButtonState extends State<AcceptRideButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    final timeoutMinutes = int.tryParse(dotenv.env['RIDE_MODAL_EXPIRE_TIME'] ?? '') ?? 2;
    _controller = AnimationController(
      duration: Duration(minutes: timeoutMinutes),
      vsync: this,
    );

    // Green shrinks from RIGHT → LEFT (starts full width, ends empty)
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isExpired = true;
          });
        }
      }
    });

    _controller.forward();
  }

  // Call this when a new ride request arrives to reset the timer
  void resetButton() {
    if (!mounted) return;
    _controller.reset();
    setState(() {
      _isExpired = false;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _isExpired ?  (){
            final userController = Get.find<UserController>();
            final mapOPTController = Get.find<MapOPTController>();
                mapOPTController.isPassengerRequest.value = false;
                userController.userModel.value?.driverProfile?.isOnline = true;
          }: widget.onPressed,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 60,
              child: _isExpired

              // ── EXPIRED STATE ──────────────────────────────────
                  ? Container(
                color: Colors.grey,
                alignment: Alignment.center,
                child: const Text(
                  'Expired',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )

              // ── ACTIVE STATE ───────────────────────────────────
                  : Stack(
                children: [
                  // ── Layer 1: Dark grey base (always full width) ──
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF3A3A3A),
                  ),

                  // ── Layer 2: Green shrinks right → left over time ──
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: _animation.value, // 1.0 → 0.0
                      child: Container(
                        color: const Color(0xFF00C853),
                      ),
                    ),
                  ),

                  // ── Layer 3: Text always perfectly centered on top ──
                  const Center(
                    child: Text(
                      'Accept Ride',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}