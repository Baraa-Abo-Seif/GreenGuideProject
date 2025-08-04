import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/scanner_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? _message = "Loading...";
  final imagePicker = ImagePicker();
  final storage = const FlutterSecureStorage();
  static const String url = 'http://192.168.227.125:8000';
  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      displayingAnswers();
    });
  }

  Future<void> displayingAnswers() async {
    final File? image = await takePhoto();
    if (image == null) {
      setState(() {
        _message = "No image selected.";
      });
      return;
    }

    Future<void> _speak(String text, String token) async {
  final Uri apiUrl = Uri.parse('$url/Users/get_voice');

  final response = await http.post(
    apiUrl,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'text': text,
    }),
  );

  if (response.statusCode == 200) {
    final Uint8List audioBytes = response.bodyBytes;
    final player = AudioPlayer();
    await player.play(BytesSource(audioBytes));
  } else {
    print('Failed to fetch voice. Status: ${response.statusCode}');
  }
}


    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );

    try {
      final accessToken = await storage.read(key: 'glasses_access_token');
      final refreshToken = await storage.read(key: 'refresh_token');
      final deviceId = await storage.read(key: 'device_id');

      if (accessToken == null || refreshToken == null || deviceId == null) {
        Navigator.of(context).pop();
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ScannerPage()));
        return;
      }

      bool isTokenValid = await _checkAccessToken(accessToken);

      String? finalToken = accessToken;

      if (!isTokenValid) {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken == null) {
          Navigator.of(context).pop();
          if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ScannerPage()));
          return;
        }

        await storage.write(key: 'glasses_access_token', value: newToken);
        finalToken = newToken;
      }

      final isDeviceValid = await _validateDeviceID(finalToken, deviceId);
      if (!isDeviceValid) {
        Navigator.of(context).pop();
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ScannerPage()));
        return;
      }

      final responseMessage = await sendRequest(image, finalToken);
      setState(() {
        _message = responseMessage;
      });

      await _speak(responseMessage, finalToken);

    } catch (e) {
      setState(() {
        _message = "An error occurred: ${e.toString()}";
      });
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<File?> takePhoto() async {
    final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    return File(image.path);
  }

  Future<String> sendRequest(File image, String token) async {
    const String apiUrl = '$url/Users/send_prompt';
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);
        return decodedData['message'] ?? "No message returned.";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: Unable to send image.";
    }
  }

  Future<bool> _checkAccessToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$url/Users/check_token'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
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
    return Scaffold(
      body: Center(child: Text(_message!)),
      floatingActionButton: FloatingActionButton(
        onPressed: displayingAnswers,
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
