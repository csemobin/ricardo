import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';

bool _isSnackbarVisible = false;

/// Shows an animated [SnackBar] via [ScaffoldMessenger].
/// If a snackbar is already visible the call is ignored — no stacking.
///
/// - title == 'Error'   → red   (AppColors.errorColor)
/// - title == 'Success' → green (AppColors.successColor)
/// - anything else      → dark neutral #323232
void showSnackbar(
  String title,
  String message, {
  BuildContext? context,
  SnackPosition? snackPosition, // kept for API compatibility
  Color? backgroundColor,
  Color? colorText,
  Duration? duration,
  EdgeInsets? margin,
  EdgeInsets? padding,
  double? borderRadius,
  bool? isDismissible,
}) {
  if (_isSnackbarVisible) return;

  final ctx = context ?? Get.context;
  if (ctx == null) return;

  _isSnackbarVisible = true;

  final messenger = ScaffoldMessenger.of(ctx);
  messenger.clearSnackBars();

  final controller = messenger.showSnackBar(
    SnackBar(
      content: _AnimatedSnackContent(
        title: title,
        message: message,
        colorText: colorText ?? Colors.white,
      ),
      backgroundColor: backgroundColor ?? _colorForTitle(title),
      behavior: SnackBarBehavior.floating,
      margin: margin ?? const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
      duration: duration ?? const Duration(seconds: 4),
      dismissDirection: (isDismissible ?? true)
          ? DismissDirection.horizontal
          : DismissDirection.none,
    ),
  );

  // Reset the guard once the snackbar is fully closed
  controller.closed.then((_) => _isSnackbarVisible = false);
}

// ---------------------------------------------------------------------------
// Animated content — slide-up + fade-in on enter
// ---------------------------------------------------------------------------

class _AnimatedSnackContent extends StatefulWidget {
  const _AnimatedSnackContent({
    required this.title,
    required this.message,
    required this.colorText,
  });

  final String title;
  final String message;
  final Color colorText;

  @override
  State<_AnimatedSnackContent> createState() => _AnimatedSnackContentState();
}

class _AnimatedSnackContentState extends State<_AnimatedSnackContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title.isNotEmpty)
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.colorText,
                  fontSize: 14,
                ),
              ),
            Text(
              widget.message,
              style: TextStyle(
                color: widget.colorText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Colour helper
// ---------------------------------------------------------------------------

Color _colorForTitle(String title) {
  switch (title.toLowerCase()) {
    case 'error':
      return AppColors.errorColor;
    case 'success':
      return AppColors.successColor;
    default:
      return const Color(0xFF323232);
  }
}
