import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/scan_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late MobileScannerController _cameraController;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
    // Reset provider state on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().resetScanner();
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String code = barcodes.first.rawValue!;
      _processCode(code);
    }
  }

  Future<void> _processCode(String code) async {
    setState(() {
      _isScanning = false;
    });

    final provider = context.read<ScanProvider>();
    await provider.processCode(code);

    if (mounted) {
      _showResultDialog(context, provider);
    }
  }

  void _showResultDialog(BuildContext context, ScanProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResultSheet(
        status: provider.status,
        message: provider.message,
        result: provider.lastResult,
        onScanNext: () {
          Navigator.pop(context);
          provider.resetScanner();
          setState(() {
            _isScanning = true;
          });
        },
        onClose: () {
          Navigator.pop(context); // Close sheet
          context.pop(); // Go back to dashboard
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
            overlay: _buildOverlay(),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          
          // Flash Button
          Positioned(
            top: 50,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: _cameraController.torchState,
                  builder: (context, state, child) {
                    return Icon(
                      state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    );
                  },
                ),
                onPressed: () => _cameraController.toggleTorch(),
              ),
            ),
          ),
          
          // Text hint
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppColors.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;
  final double cutOutBottomOffset;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
    this.cutOutBottomOffset = 0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize != 0.0 ? cutOutSize : 300.0; // Fixed size
    final _cutOutBottomOffset = cutOutBottomOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + _cutOutBottomOffset + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    final borderRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    // Draw corners
    _drawCorners(canvas, borderRect, borderPaint);
  }
  
  void _drawCorners(Canvas canvas, RRect borderRect, Paint paint) {
    final path = Path();
    
    // Top left
    path.moveTo(borderRect.left, borderRect.top + borderLength);
    path.lineTo(borderRect.left, borderRect.top);
    path.lineTo(borderRect.left + borderLength, borderRect.top);
    
    // Top right
    path.moveTo(borderRect.right - borderLength, borderRect.top);
    path.lineTo(borderRect.right, borderRect.top);
    path.lineTo(borderRect.right, borderRect.top + borderLength);
    
    // Bottom right
    path.moveTo(borderRect.right, borderRect.bottom - borderLength);
    path.lineTo(borderRect.right, borderRect.bottom);
    path.lineTo(borderRect.right - borderLength, borderRect.bottom);
    
    // Bottom left
    path.moveTo(borderRect.left + borderLength, borderRect.bottom);
    path.lineTo(borderRect.left, borderRect.bottom);
    path.lineTo(borderRect.left, borderRect.bottom - borderLength);
    
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

class _ResultSheet extends StatelessWidget {
  final ScanStatus status;
  final String? message;
  final Map<String, dynamic>? result;
  final VoidCallback onScanNext;
  final VoidCallback onClose;

  const _ResultSheet({
    required this.status,
    this.message,
    this.result,
    required this.onScanNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == ScanStatus.success;
    final color = isSuccess ? Colors.green : Colors.red;
    final icon = isSuccess ? Icons.check_circle : Icons.error;
    final title = isSuccess ? 'Valid Ticket' : 'Validation Failed';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
          
          if (isSuccess && result != null) ...[
            const SizedBox(height: 24),
            _DetailRow(label: 'Attendee', value: result!['attendeeName'] ?? 'Unknown'),
            _DetailRow(label: 'Event', value: result!['eventName'] ?? 'Unknown'),
            _DetailRow(label: 'Ticket Type', value: result!['ticketType'] ?? 'General'),
          ],
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onScanNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Scan Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
