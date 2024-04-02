import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class CameraWidget extends StatefulWidget {
  final CameraController controller;

  const CameraWidget(
      this.controller,

      {Key? key}
      ) : super(key: key);

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  XFile? _capturedImage;
  FlashMode _currentFlashMode = FlashMode.off;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: <Widget>[
              CustomPaint(
                foregroundPainter: MyPainter(),
                child: CameraPreview(widget.controller),
              ),
              ClipPath(
                clipper: MyClipper(),
                child: CameraPreview(widget.controller),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Make sure the picture is clear and not blurry",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Secondary contact number text field
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: _toggleFlash,
                    child: Icon(_getFlashIcon()),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      try {
                        final image = await widget.controller.takePicture();
                        setState(() {
                          _capturedImage = image;
                        });
                        _showPreviewDialog();
                      } catch (e) {
                        print('Error taking picture: $e');
                      }
                    },
                    child: const Icon(Icons.camera),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleFlash() {
    setState(() {
      if (_currentFlashMode case FlashMode.off) {
        _currentFlashMode = FlashMode.auto;
      } else if (_currentFlashMode case FlashMode.auto) {
        _currentFlashMode = FlashMode.always;
      } else if (_currentFlashMode case FlashMode.always) {
        _currentFlashMode = FlashMode.off;
      }
    });
    widget.controller.setFlashMode(_currentFlashMode);
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  // Inside _MyCameraWidgetState class
  void _showPreviewDialog() async {
    if (_capturedImage != null) {
      final Uint8List bytes = await File(_capturedImage!.path).readAsBytes();
      final img.Image capturedImg = img.decodeImage(bytes)!;

      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;

      final double cropWidth = screenWidth - 260; // Adjust as needed
      const double cropHeight = 460; // Adjust as needed

// Calculate the top-left corner of the crop box
      final double cropLeft = (capturedImg.width - cropWidth) / 2;
      final double cropTop = (capturedImg.height - cropHeight) / 2;

      final img.Image croppedImage = img.copyCrop(
        capturedImg,
        cropLeft.toInt(),
        cropTop.toInt(),
        cropWidth.toInt(),
        cropHeight.toInt(),
      );

      final img.Image finalImage = img.copyRotate(croppedImage, 90);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Preview'),
          content: SizedBox(
            width: double.infinity,
            child: Image.memory(Uint8List.fromList(img.encodeJpg(finalImage))),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle the confirmed image, e.g., save it or use it
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _capturedImage = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Retake'),
            ),
          ],
        ),
      );
    }
  }



}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.8), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, size.height / 2 - 125, size.width - 0, 250), const Radius.circular(26)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    return true;
  }
}
