import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../core/theme/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  final TicketRepository _ticketRepository = TicketRepository();
  bool _isProcessing = false;
  final TextEditingController _manualController = TextEditingController();

  @override
  void dispose() {
    _cameraController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _validateTicket(barcode.rawValue!);
        break; // Only process one code
      }
    }
  }

  Future<void> _validateTicket(String ticketId) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Parse ticket ID from QR (handle optional "ticketId,eventId" format)
      String tId = ticketId.trim();
      String eId = '';
      if (ticketId.contains(',')) {
        final parts = ticketId.split(',');
        tId = parts[0].trim();
        if (parts.length > 1) eId = parts[1].trim();
      }

      // Single API call — backend validates without requiring eventId
      final result = await _ticketRepository.validateTicket(tId, eId);

      if (mounted) {
        _showResultDialog(
          success: true,
          title: 'Check-in Successful ✓',
          message: 'Welcome, ${result['user']?['name'] ?? 'Attendee'}!',
        );
      }
    } catch (e) {
      if (mounted) {
        _showResultDialog(
          success: false,
          title: 'Check-in Failed',
          message: e.toString().replaceAll('Exception:', '').trim(),
        );
      }
    }
  }

  void _showResultDialog({required bool success, required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: success ? Colors.green[50] : Colors.red[50],
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: success ? Colors.green[900] : Colors.red[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset scanner state so next QR can be scanned
              setState(() {
                _isProcessing = false;
              });
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: success ? Colors.green[900] : Colors.red[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).then((_) {
      // Also reset if dismissed by tapping outside the dialog
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Ticket'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
           Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _cameraController,
                  onDetect: _onDetect,
                ),
                // Overlay
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _isProcessing ? 'Processing...' : 'Align QR code within the frame',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Manual Entry
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Or enter ticket ID manually',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualController,
                        decoration: const InputDecoration(
                          hintText: 'Ticket ID',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                              if (_manualController.text.isNotEmpty) {
                                _validateTicket(_manualController.text.trim());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
