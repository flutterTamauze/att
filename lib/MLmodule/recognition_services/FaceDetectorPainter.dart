import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

const List<Point<int>> faceMaskConnections = [
  Point(0, 4),
  Point(0, 55),
  Point(4, 7),
  Point(4, 55),
  Point(4, 51),
  Point(7, 11),
  Point(7, 51),
  Point(7, 130),
  Point(51, 55),
  Point(51, 80),
  Point(55, 72),
  Point(72, 76),
  Point(76, 80),
  Point(80, 84),
  Point(84, 72),
  Point(72, 127),
  Point(72, 130),
  Point(130, 127),
  Point(117, 130),
  Point(11, 117),
  Point(11, 15),
  Point(15, 18),
  Point(18, 21),
  Point(21, 121),
  Point(15, 121),
  Point(21, 25),
  Point(25, 125),
  Point(125, 128),
  Point(128, 127),
  Point(128, 29),
  Point(25, 29),
  Point(29, 32),
  Point(32, 0),
  Point(0, 45),
  Point(32, 41),
  Point(41, 29),
  Point(41, 45),
  Point(45, 64),
  Point(45, 32),
  Point(64, 68),
  Point(68, 56),
  Point(56, 60),
  Point(60, 64),
  Point(56, 41),
  Point(64, 128),
  Point(64, 127),
  Point(125, 93),
  Point(93, 117),
  Point(117, 121),
  Point(121, 125),
];

class FaceDetectorPainter extends CustomPainter {
  final Size absulteImageSize;
  final List<Face> faces;
  CameraLensDirection cameraLensDirection;

  FaceDetectorPainter(
      this.absulteImageSize, this.faces, this.cameraLensDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absulteImageSize.width;
    final double scaleY = size.height / absulteImageSize.height;
    Paint paint;
    if (this.faces[0].headEulerAngleY > 10 ||
        this.faces[0].headEulerAngleY < -10) {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.red;
    } else {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.green;
    }
    final Paint greenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.green;
    for (Face face in faces) {
      final contour = face.getContour((FaceContourType.allPoints));
      canvas.drawRect(
          Platform.isIOS
              ? Rect.fromLTRB(
                  cameraLensDirection == CameraLensDirection.front
                      ? face.boundingBox.left * scaleY
                      : (absulteImageSize.width - face.boundingBox.right) *
                          scaleX,
                  face.boundingBox.top * scaleY,
                  cameraLensDirection == CameraLensDirection.front
                      ? face.boundingBox.right * scaleY
                      : (absulteImageSize.width - face.boundingBox.left) *
                          scaleX,
                  face.boundingBox.bottom * scaleY)
              : Rect.fromLTRB(
                  cameraLensDirection == CameraLensDirection.back
                      ? face.boundingBox.left * scaleY
                      : (absulteImageSize.width - face.boundingBox.right) *
                          scaleX,
                  face.boundingBox.top * scaleY,
                  cameraLensDirection == CameraLensDirection.back
                      ? face.boundingBox.right * scaleY
                      : (absulteImageSize.width - face.boundingBox.left) *
                          scaleX,
                  face.boundingBox.bottom * scaleY),
          paint);

      // for (final connection in faceMaskConnections) {
      //   canvas.drawLine(
      //       contour.positionsList[connection.x].scale(scaleX, scaleY),
      //       contour.positionsList[connection.y].scale(scaleX, scaleY),
      //       paint);
      // }
      // canvas.drawRect(
      //   Rect.fromLTRB(
      //     face.boundingBox.left * scaleX,
      //     face.boundingBox.top * scaleY,
      //     face.boundingBox.right * scaleX,
      //     face.boundingBox.bottom * scaleY,
      //   ),
      //   greenPaint,
      // );
    }
  }

  @override
  bool shouldRepaint(covariant FaceDetectorPainter oldDelegate) {
    return oldDelegate.absulteImageSize != absulteImageSize ||
        oldDelegate.faces != faces;
  }
}
