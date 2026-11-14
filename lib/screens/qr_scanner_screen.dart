import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _codeController = TextEditingController();
  final _scannerController = MobileScannerController();
  bool _isScanning = true;

  bool get _cameraSupported =>
      kIsWeb ||
      {
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform);

  @override
  void dispose() {
    _codeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Claim via QR')),
      body: Column(
        children: [
          Expanded(
            child: _cameraSupported
                ? _isScanning
                    ? MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          for (final barcode in capture.barcodes) {
                            final code = barcode.rawValue;
                            if (code != null && code.isNotEmpty) {
                              _verifyCode(state, code);
                              break;
                            }
                          }
                        },
                      )
                    : const Center(child: CircularProgressIndicator())
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner, size: 56),
                          SizedBox(height: 12),
                          Text(
                            'Camera scanning is not available on this device. '
                            'Enter the verification code below.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _codeController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (code) => _verifyCode(state, code),
                    decoration: const InputDecoration(
                      labelText: 'Verification code',
                      hintText: 'Enter the code shown with the QR',
                      prefixIcon: Icon(Icons.qr_code),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _verifyCode(state, _codeController.text),
                      icon: const Icon(Icons.verified),
                      label: const Text('Verify code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyCode(AppState state, String code) {
    final value = code.trim();
    if (value.isEmpty || !_isScanning && _cameraSupported) return;

    FocusScope.of(context).unfocus();
    setState(() => _isScanning = false);
    _showResult(context, state.verifyQR(value));
  }

  void _showResult(BuildContext context, bool success) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? Colors.green : Colors.red,
          size: 64,
        ),
        content: Text(
          success
              ? 'Verification successful. The claim has been verified.'
              : 'Verification failed. The code is invalid or the claim is not approved.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (success) {
                Navigator.pop(context);
              } else if (mounted) {
                setState(() {
                  _isScanning = true;
                  _codeController.clear();
                });
              }
            },
            child: Text(success ? 'Finish' : 'Try again'),
          ),
        ],
      ),
    );
  }
}
