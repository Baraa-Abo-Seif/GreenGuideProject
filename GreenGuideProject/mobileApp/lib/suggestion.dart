import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'login.dart';
import 'settings_screen.dart';

class Suggestion extends StatefulWidget {
  final String label;

  const Suggestion({super.key, required this.label});

  @override
  State<Suggestion> createState() => _SuggestionState();
}

class _SuggestionState extends State<Suggestion> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _suggestionText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestion();
  }

  Future<void> _loadSuggestion() async {
    String? accessToken = await _storage.read(key: 'access_token');
    String? refreshToken = await _storage.read(key: 'refresh_token');

    if (accessToken == null || refreshToken == null) {
      _redirectToLogin();
      return;
    }

    try {
      final suggestion = await ApiService.getSuggestion(
        accessToken: accessToken,
        promptText: widget.label,
      );
      setState(() {
        _suggestionText = suggestion['message'] ?? 'No suggestion found.';
        _isLoading = false;
      });
    } on HttpException catch (e) {
      if (e.message.contains('expired')) {
        // Try refreshing the token
        String? newAccessToken = await ApiService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await _storage.write(key: 'access_token', value: newAccessToken);
          _loadSuggestion(); // Retry after refresh
        } else {
          _redirectToLogin();
        }
      } else {
        setState(() {
          _suggestionText = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _suggestionText = 'Something went wrong.';
        _isLoading = false;
      });
    }
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const String userName = "User";

    return Scaffold(
      backgroundColor: const Color(0xFFEBF1EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hi $userName", style: const TextStyle(fontSize: 24)),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/profile.png'),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        child: Image.asset(
                          'assets/settings.png',
                          width: 26,
                          height: 26,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),

              // Expanded container fills remaining space
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Text(
                            _suggestionText,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
