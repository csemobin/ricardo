import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';

class DraggableLocationShowButton extends StatefulWidget {
  final MapOPTController mapOPTController;
  final GestureTapCallback onTap;

  const DraggableLocationShowButton(
      {super.key, required this.mapOPTController, required this.onTap});

  @override
  State<DraggableLocationShowButton> createState() =>
      _DraggableLocationShowButtonState();
}

class _DraggableLocationShowButtonState
    extends State<DraggableLocationShowButton> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isVisible = widget.mapOPTController.isLocationButtonVisible.value;

        return Positioned(
          top: widget.mapOPTController.buttonTop.value,
          right: widget.mapOPTController.buttonRight.value,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !isVisible,
              child: GestureDetector(
                onPanUpdate: (details) {
                  final size = MediaQuery.of(context).size;

                  const buttonSize = 56.0;
                  const topPadding = 80.0;
                  const bottomPadding = 180.0;

                  final newTop = widget.mapOPTController.buttonTop.value +
                      details.delta.dy;

                  final newRight = widget.mapOPTController.buttonRight.value -
                      details.delta.dx;

                  widget.mapOPTController.buttonTop.value = newTop.clamp(
                    topPadding,
                    size.height - bottomPadding,
                  );

                  widget.mapOPTController.buttonRight.value = newRight.clamp(
                    10.0,
                    size.width - buttonSize - 10,
                  );
                },
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: widget.onTap,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        size: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
