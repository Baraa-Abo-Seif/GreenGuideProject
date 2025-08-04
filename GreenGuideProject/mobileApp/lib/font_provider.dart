import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'font_size_factor';
  double _fontSizeFactor = 1.0;
  
  // Minimum and maximum font size scaling factors
  final double _minFontSize = 0.8;
  final double _maxFontSize = 1.2;
  final double _fontSizeStep = 0.1;

  // Constructor loads saved font size from shared preferences
  FontSizeProvider() {
    _loadFontSize();
  }

  // Public getter for fontSizeFactor
  double get fontSizeFactor => _fontSizeFactor;

  // Increase font size
  void increaseFontSize() {
    if (_fontSizeFactor < _maxFontSize) {
      _fontSizeFactor += _fontSizeStep;
      _saveFontSize();
      notifyListeners();
    }
  }

  // Decrease font size
  void decreaseFontSize() {
    if (_fontSizeFactor > _minFontSize) {
      _fontSizeFactor -= _fontSizeStep;
      _saveFontSize();
      notifyListeners();
    }
  }

  // Set specific font size
  void setFontSize(double size) {
    if (size >= _minFontSize && size <= _maxFontSize) {
      _fontSizeFactor = size;
      _saveFontSize();
      notifyListeners();
    }
  }

  // Reset to default font size
  void resetFontSize() {
    _fontSizeFactor = 1.0;
    _saveFontSize();
    notifyListeners();
  }

  // Save font size to SharedPreferences
  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSizeFactor);
  }

  // Load font size from SharedPreferences
  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSizeFactor = prefs.getDouble(_fontSizeKey) ?? 1.0;
    notifyListeners();
  }
}
