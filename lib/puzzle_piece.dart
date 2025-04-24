import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PuzzlePiece extends StatelessWidget {
  final ui.Image image;
  final int row;
  final int col;
  final double imageSize;

  const PuzzlePiece({
    super.key,
    required this.image,
    required this.row,
    required this.col,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: CustomPaint(
          size: Size(imageSize / 3, imageSize / 3),
          painter: _PiecePainter(
            image: image,
            row: row,
            col: col,
            imageSize: imageSize,
          ),
        ),
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final ui.Image image;
  final int row;
  final int col;
  final double imageSize;

  _PiecePainter({
    required this.image,
    required this.row,
    required this.col,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pieceWidth = image.width / 3;
    final pieceHeight = image.height / 3;

    final src = Rect.fromLTWH(
      col * pieceWidth,
      row * pieceHeight,
      pieceWidth,
      pieceHeight,
    );

    final dst = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(image, src, dst, Paint());

    // Draw a subtle border around each piece
    final borderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(dst, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
