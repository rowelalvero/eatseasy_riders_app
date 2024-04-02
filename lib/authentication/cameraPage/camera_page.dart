import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../imageGetters/rider_profile.dart';


class CameraWidget extends StatefulWidget {

  bool isFrontLicense;

  CameraWidget({
    Key? key,
    required this.isFrontLicense,
  }) : super(key: key);


  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? _controller;
  XFile? _capturedImage;
  FlashMode _currentFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    setState(() {
      _capturedImage = null; // Reset captured image before capturing a new one

    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      print("No cameras available");
      return;
    }
    _controller = CameraController(cameras[0], ResolutionPreset.low);
    await _controller?.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 198, 65),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Take Photo",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 67, 83, 89),
                  ),
                ),
              ],
            ),
          ],
        ),
        //appBar elevation/shadow
        elevation: 2,
        centerTitle: true,
        leadingWidth: 40.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0), // Adjust the left margin here
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded), // Change this icon to your desired icon
            onPressed: () {
              // Add functionality to go back
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column (
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Stack(
              children: <Widget>[
                CustomPaint(
                  foregroundPainter: MyPainter(),
                  child: CameraPreview(_controller!),
                ),
                ClipPath(
                  clipper: MyClipper(),
                  child: CameraPreview(_controller!),
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
                          final image = await _controller?.takePicture();
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
      ),


    );
  }

  void _toggleFlash() {
    setState(() {
      if (_currentFlashMode == FlashMode.off) {
        _currentFlashMode = FlashMode.auto;
      } else if (_currentFlashMode == FlashMode.auto) {
        _currentFlashMode = FlashMode.always;
      } else if (_currentFlashMode == FlashMode.always) {
        _currentFlashMode = FlashMode.off;
      }
    });
    _controller?.setFlashMode(_currentFlashMode);
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

  void _showPreviewDialog() async {

    if (_capturedImage != null) {
      final Uint8List bytes = await File(_capturedImage!.path).readAsBytes();
      final img.Image capturedImg = img.decodeImage(bytes)!;

      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;

      final double cropWidth = screenWidth - 260; // Adjust as needed
      const double cropHeight = 460; // Adjust as needed

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
                // Update the state to store the captured image
                if (widget.isFrontLicense) {
                  frontLicense = _capturedImage;
                  Navigator.pop(context);
                } else {
                  backLicense = _capturedImage;
                  Navigator.pop(context);
                }
                // Navigate back to the previous screen
                Navigator.pop(context);
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
