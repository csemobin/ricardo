import 'package:flutter/material.dart';

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

    // 2 minutes duration
    _controller = AnimationController(
      duration: const Duration(minutes: 2),
      vsync: this,
    );

    // Animation from 1.0 to 0.0 (green portion shrinks)
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isExpired = true;
        });
      }
    });

    // Start animation
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
        return InkWell(
          onTap: _isExpired ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: _isExpired ? Colors.grey : null,
            ),
            child: _isExpired
                ? Center(
              child: Text(
                'Expired',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Row(
                children: [
                  // Dark grey portion (grows as green shrinks)
                  Expanded(
                    flex: (100 - (_animation.value * 100)).toInt(),
                    child: Container(
                      color: Color(0xFF3A3A3A),
                      child: Center(
                        child: Text(
                          'Accept Ride',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Green portion (shrinks over time)
                  if (_animation.value > 0)
                    Expanded(
                      flex: (_animation.value * 100).toInt(),
                      child: Container(
                        color: Color(0xFF00C853),
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