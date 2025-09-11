import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    final back = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => widget.cameras.first,
    );
    _controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initFuture = _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder(
              future: _initFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                return CameraPreview(_controller!);
              },
            ),
            // Overlay guide for 8.5 x 5.4 frame
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _IdCardFramePainter()),
              ),
            ),
            // Top bar
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Bottom capture bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_controller == null) return;
                      try {
                        final file = await _controller!.takePicture();
                        if (!mounted) return;
                        Navigator.of(context).pop(file);
                      } catch (_) {}
                    },
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdCardFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);

    // Full-screen dim
    canvas.drawRect(Offset.zero & size, paint);

    // Target aspect ratio 8.5 : 5.4 (approx 1.574)
    const targetRatio = 8.5 / 5.4;
    double w = size.width * 0.9; // leave margin
    double h = w / targetRatio;
    if (h > size.height * 0.6) {
      h = size.height * 0.6;
      w = h * targetRatio;
    }
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.48),
      width: w,
      height: h,
    );

    // Clear center
    final clear = Paint()..blendMode = BlendMode.clear;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, clear);
    canvas.restore();

    // White border with corner accents
    final border =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white
          ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      border,
    );

    // Corners
    final corner =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.lightBlueAccent
          ..strokeWidth = 3.0;
    const len = 18.0;
    // TL
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(len, 0), corner);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, len), corner);
    // TR
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(-len, 0),
      corner,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(0, len),
      corner,
    );
    // BL
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(len, 0),
      corner,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -len),
      corner,
    );
    // BR
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-len, 0),
      corner,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -len),
      corner,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
