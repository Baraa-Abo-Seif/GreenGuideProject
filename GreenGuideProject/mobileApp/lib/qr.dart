import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import 'api_service.dart'; // Make sure this points to your ApiService file
import 'l10n/app_localizations.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final _storage = const FlutterSecureStorage();
  String _qrData = "";
  bool _showPopup = false;

  @override
  void initState() {
    super.initState();
    _loadEncryptedInfo();
  }

  Future<void> _loadEncryptedInfo() async {
    String? accessToken = await _storage.read(key: 'access_token');
    String? refreshToken = await _storage.read(key: 'refresh_token');

    if (refreshToken == null || accessToken == null) {
      _goToLogin();
      return;
    }

    final success = await _tryFetchEncryptedInfo(accessToken, refreshToken);

    if (!success) {
      _goToLogin();
    }
  }


  Future<bool> _tryFetchEncryptedInfo(String accessToken, String refreshToken) async {
    try {
      final encryptedData = await ApiService.getEncryptedUserInfo(accessToken);
      final deviceIDSet = await ApiService.checkDeviceID(accessToken);

      if (mounted) {
        setState(() {
          _qrData = encryptedData['encrypted_data'] ?? 'No info';
          _showPopup = deviceIDSet == false;
        });

        if (_showPopup) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(context: context, builder: _buildPopup);
          });
        }
      }

      return true;
    } catch (e) {
      // Try to refresh token
      final newAccessToken = await ApiService.refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        await _storage.write(key: 'access_token', value: newAccessToken);
        return await _tryFetchEncryptedInfo(newAccessToken, refreshToken);
      }
    }
    return false;
  }

  void _goToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color.fromRGBO(66, 132, 66, 1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                height: constraints.maxHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.12),
                    // QR Code Container
                    GestureDetector(
                      onTap: _showPopup
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) => _buildPopup(context),
                              );
                            }
                          : null,
                      child: Container(
                        width: constraints.maxWidth * 0.6,
                        height: constraints.maxWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: Size(constraints.maxWidth * 0.6, constraints.maxWidth * 0.6),
                              painter: _CornerBorderPainter(),
                            ),
                            Center(
                              child: QrImageView(
                                data: _qrData.isNotEmpty ? _qrData : "Loading...",
                                version: QrVersions.auto,
                                size: constraints.maxWidth * 0.5,
                                gapless: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.05),
                    Text(
                      localizations.scanQRCode,
                      style: TextStyle(
                        fontSize: constraints.maxHeight < 600 ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.04),
                    Text(
                      localizations.glassesSetup,
                      style: TextStyle(
                        fontSize: constraints.maxHeight < 600 ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.1,
                      ),
                      child: Text(
                        localizations.scanQRDescription,
                        style: TextStyle(
                          fontSize: constraints.maxHeight < 600 ? 14 : 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPopup(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/success_connection.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            localizations.glassesConnected,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0037A6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations.done,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0DFF39)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    const radius = 20.0;

    canvas.drawArc(const Rect.fromLTWH(0, 0, radius * 2, radius * 2), pi, pi / 2, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2), -pi / 2, pi / 2, false, paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2), pi / 2, pi / 2, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width - radius * 2, size.height - radius * 2, radius * 2, radius * 2), 0, pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
