import 'package:flutter/material.dart';

class PDFExportButton extends StatelessWidget {
  final String title;
  final String icon;
  final Function() onExport;
  final bool isExporting;

  const PDFExportButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onExport,
    this.isExporting = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isExporting ? null : onExport,
      icon: isExporting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Icon(
              _getIcon(),
              size: 18,
            ),
      label: Text(
        isExporting ? 'Generating...' : title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: Colors.red.shade300),
        foregroundColor: Colors.red.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (icon) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'share':
        return Icons.share;
      case 'print':
        return Icons.print;
      case 'download':
        return Icons.download;
      default:
        return Icons.picture_as_pdf;
    }
  }
}
