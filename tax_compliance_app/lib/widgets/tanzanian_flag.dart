import 'package:flutter/material.dart';

class TanzanianFlag extends StatelessWidget {
  final double width;
  final double height;

  const TanzanianFlag({
    super.key,
    this.width = 60,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Stack(
        children: [
          // Green top section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.45,
            child: Container(color: const Color(0xFF1EBE53)),
          ),
          // Blue bottom section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: height * 0.45,
            child: Container(color: const Color(0xFF00A3E0)),
          ),
          // Yellow diagonal stripe (left to right)
          Positioned.fill(
            child: CustomPaint(
              painter: _DiagonalStripePainter(
                color: const Color(0xFFFBD914),
                width: height * 0.09,
                isYellow: true,
              ),
            ),
          ),
          // Black diagonal stripe (left to right)
          Positioned.fill(
            child: CustomPaint(
              painter: _DiagonalStripePainter(
                color: const Color(0xFF1A1A1A),
                width: height * 0.07,
                isYellow: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalStripePainter extends CustomPainter {
  final Color color;
  final double width;
  final bool isYellow;

  _DiagonalStripePainter({
    required this.color,
    required this.width,
    required this.isYellow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double offset = isYellow ? 0 : width * 0.1;

    final path = Path();
    path.moveTo(0, size.height * 0.4 + offset);
    path.lineTo(size.width * 0.3 - width * 0.5, size.height * 0.4 + offset);
    path.lineTo(size.width * 0.3 + width * 0.5, size.height * 0.6 - offset);
    path.lineTo(size.width * 0.7 - width * 0.5, size.height * 0.6 - offset);
    path.lineTo(size.width * 0.7 + width * 0.5, size.height * 0.8 + offset);
    path.lineTo(size.width, size.height * 0.8 + offset);
    path.lineTo(size.width, size.height * 0.6 - offset);
    path.lineTo(size.width * 0.7 + width * 0.5, size.height * 0.6 - offset);
    path.lineTo(size.width * 0.7 - width * 0.5, size.height * 0.4 + offset);
    path.lineTo(size.width * 0.3 + width * 0.5, size.height * 0.4 + offset);
    path.lineTo(size.width * 0.3 - width * 0.5, size.height * 0.2 - offset);
    path.lineTo(0, size.height * 0.2 - offset);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
