import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class PremiumDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const PremiumDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTheme.titleStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Material(
                  color: Colors.transparent,
                  child: content,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Colors.white10),
              IntrinsicHeight(
                child: Row(
                  children: actions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final widget = entry.value;
                    return Expanded(
                      child: Row(
                        children: [
                          if (index > 0) const VerticalDivider(width: 1, color: Colors.white10),
                          Expanded(child: widget),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showPremiumDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<Widget> actions,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim1, anim2) => PremiumDialog(
      title: title,
      content: content,
      actions: actions,
    ),
    transitionBuilder: (ctx, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: anim1.drive(Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic))),
          child: child,
        ),
      );
    },
  );
}
