import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_application_1/home_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<ScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool _isScanning = true;

  static const String deviceIdKey = 'device_id';
  static const String apiUrl = 'http://192.168.227.125:8000/Users/login_glasses';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await secureStorage.read(key: deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await secureStorage.write(key: deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  Future<void> _handleBarcode(String code) async {
    if (!_isScanning) return;
    _isScanning = false;
    controller.stop();

    final deviceId = await _getOrCreateDeviceId();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'encrypted_data': code,
          'device_id': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        await secureStorage.write(key: 'glasses_access_token', value: body['glasses_access_token']);
        await secureStorage.write(key: 'refresh_token', value: body['refresh_token']);
        await secureStorage.write(key: deviceIdKey, value: deviceId);
        

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } else {
        _retryScan('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      _retryScan('Error: $e');
    }
  }

  void _retryScan(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      _isScanning = true;
      controller.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) {
          for (final barcode in capture.barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              debugPrint('Barcode found! $code');
              _handleBarcode(code);
              break;
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.flash_on),
        onPressed: () => controller.toggleTorch(),
      ),
    );
  }
}
