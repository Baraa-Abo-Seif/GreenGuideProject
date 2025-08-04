import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/scanner_page.dart';
import 'package:flutter_application_1/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();
  Widget _startPage = const Scaffold(body: Center(child: CircularProgressIndicator()));
  static const String url = 'http://192.168.227.125:8000';

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
  final accessToken = await storage.read(key: 'glasses_access_token');
  final refreshToken = await storage.read(key: 'refresh_token');
  final deviceId = await storage.read(key: 'device_id');

  if (accessToken == null || refreshToken == null || deviceId == null) {
    setState(() => _startPage = const ScannerPage());
    return;
  }

  bool isTokenValid = await _checkAccessToken(accessToken);

  if (!isTokenValid) {
    final newToken = await _refreshAccessToken(refreshToken);

    if (newToken == null) {
      // Refresh failed, go to scanner
      setState(() => _startPage = const ScannerPage());
      return;
    }

    await storage.write(key: 'glasses_access_token', value: newToken);
  }

  // Get updated token after refresh
  final updatedToken = await storage.read(key: 'glasses_access_token');
  bool isDeviceValid = await _validateDeviceID(updatedToken!, deviceId);

  setState(() {
    _startPage = isDeviceValid ? const HomePage() : const ScannerPage();
  });
}


  Future<bool> _checkAccessToken(String token) async {
    try {
    final response = await http.get(
      Uri.parse('$url/Users/check_token'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 5));

    return response.statusCode == 200;
  } catch (_) {
    return false; // If anything goes wrong, assume token is invalid
  }
}

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$url/Users/refersh_glasses_token'),
        headers: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['glasses_access_token'];
      }
    } catch (_) {}
    return null;
  }

  Future<bool> _validateDeviceID(String token, String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/Users/validate_device_id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'device_id': deviceId}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['match'] == true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _startPage,
      debugShowCheckedModeBanner: false,
    );
  }
}

