import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class DayloTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool showError;

  const DayloTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.errorText,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.black),
          cursorColor: AppTheme.black,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTheme.labelStyle,
            floatingLabelStyle: AppTheme.labelStyle.copyWith(
              color: showError ? AppTheme.errorRed : AppTheme.darkGray,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: showError ? AppTheme.errorRed : AppTheme.mediumGray, 
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: showError ? AppTheme.errorRed : AppTheme.black, 
                width: 1.5,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.errorRed, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        if (showError && errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTheme.errorStyle,
          ),
        ],
      ],
    );
  }
}
