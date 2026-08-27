import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double? value;
  final String? label;
  final Color? color;

  const ProgressIndicatorWidget({
    super.key,
    this.value,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
        ],
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? const Color(0xFF2E7D32),
          ),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
      ],
    );
  }
}