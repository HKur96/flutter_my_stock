import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A reusable barcode/QR scanner screen.
///
/// Returns the scanned barcode value as a [String] via [Navigator.pop].
/// Usage:
/// ```dart
/// final result = await Navigator.push<String>(
///   context,
///   MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
/// );
/// ```
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _hasScanned = true;
    Navigator.pop(context, barcode.rawValue);
  }

  @override
  Widget build(BuildContext context) {
    final scanWindowSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Scan Barcode / QR',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Flashlight toggle
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, scannerState, _) {
              final torchState = scannerState.torchState;
              return IconButton(
                icon: Icon(
                  torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color: torchState == TorchState.on
                      ? AppColors.warning
                      : Colors.white70,
                ),
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
          // Camera switch
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white70),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay with scan window cutout
          _buildOverlay(scanWindowSize),

          // Bottom instruction
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Arahkan kamera ke barcode atau QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(double scanWindowSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final left = (constraints.maxWidth - scanWindowSize) / 2;
        final top = (constraints.maxHeight - scanWindowSize) / 2;

        return Stack(
          children: [
            // Semi-transparent overlay with cutout
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  // Full overlay
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  // Cutout window
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanWindowSize,
                      height: scanWindowSize,
                      decoration: BoxDecoration(
                        color: Colors.red, // Any color, will be cut out
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Corner decorations
            Positioned(
              left: left - 2,
              top: top - 2,
              child: _buildCorner(isTop: true, isLeft: true),
            ),
            Positioned(
              right: left - 2,
              top: top - 2,
              child: _buildCorner(isTop: true, isLeft: false),
            ),
            Positioned(
              left: left - 2,
              bottom:
                  constraints.maxHeight - top - scanWindowSize - 2,
              child: _buildCorner(isTop: false, isLeft: true),
            ),
            Positioned(
              right: left - 2,
              bottom:
                  constraints.maxHeight - top - scanWindowSize - 2,
              child: _buildCorner(isTop: false, isLeft: false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _CornerPainter(
          isTop: isTop,
          isLeft: isLeft,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;

  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 4);
      path.quadraticBezierTo(0, 0, 4, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width - 4, 0);
      path.quadraticBezierTo(size.width, 0, size.width, 4);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - 4);
      path.quadraticBezierTo(0, size.height, 4, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height - 4);
      path.quadraticBezierTo(
          size.width, size.height, size.width - 4, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
