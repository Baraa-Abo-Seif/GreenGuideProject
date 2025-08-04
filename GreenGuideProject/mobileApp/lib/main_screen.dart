import 'package:flutter/material.dart';
import 'choose_care.dart';
import 'settings_screen.dart';
import 'suggestion.dart';
import 'edit_profile.dart';
import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';
import 'l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  List<Map<String, String>> _features = [];

  @override
  void initState() {
    super.initState();
    _handleStartupLogic();
  }

  Future<void> _handleStartupLogic() async {
    setState(() {
      _isLoading = true;
    });

    String? accessToken = await _storage.read(key: 'access_token');
    String? refreshToken = await _storage.read(key: 'refresh_token');

    if (accessToken != null && refreshToken != null) {
      bool? isTypeIDNull = await ApiService.checkTypeID(accessToken);

      if (isTypeIDNull == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChooseCareScreen()),
        );
      } else if (isTypeIDNull == false) {
        await _loadFeatures();
      } else {
        String? newAccessToken = await ApiService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await _storage.write(key: 'access_token', value: newAccessToken);
          _handleStartupLogic();
        } else {
          _redirectToLogin();
        }
      }
    } else {
      _redirectToLogin();
    }
  }

  Future<void> _loadFeatures() async {
    String? accessToken = await _storage.read(key: 'access_token');
    String? refreshToken = await _storage.read(key: 'refresh_token');

    if (accessToken == null || refreshToken == null) {
      _redirectToLogin();
      return;
    }
    String lang = Localizations.localeOf(context).languageCode;
    var response = await ApiService.getInformationByUserType(accessToken, lang);

    if (response != null) {
      setState(() {
        _features = response!;
        _isLoading = false;
      });
    } else {
      String? newAccessToken = await ApiService.refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        await _storage.write(key: 'access_token', value: newAccessToken);
        response = await ApiService.getInformationByUserType(newAccessToken, lang);
        if (response != null) {
          setState(() {
            _features = response!;
            _isLoading = false;
          });
          return;
        }
      }
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // UI Helpers
  double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSize * (screenWidth / 375); // base iPhone width
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(206, 255, 174, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        },
                        child: Image.asset(
                          'assets/Meatballs_menu.png',
                          width: getResponsiveWidth(context, 5),
                          height: getResponsiveHeight(context, 5),
                        ),
                      ),
                      Image.asset(
                        'images/logo.png',
                        width: getResponsiveWidth(context, 35),
                        height: getResponsiveHeight(context, 7),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    },
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Suggestion Card
              Container(
                width: double.infinity,
                height: getResponsiveHeight(context, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('images/vector.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color.fromRGBO(240, 255, 230, 1),
                      BlendMode.darken,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    localizations.suggestions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromRGBO(54, 58, 51, 1),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Feature Cards Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.77,
                  children: _features.map((feature) {
                    return _buildFeatureCard(
                      feature['image_path'] ?? '',
                      feature['text'] ?? '',
                      () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => Suggestion(label: feature['text'] ?? '')));
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String imagePath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(240, 255, 230, 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imagePath,
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(54, 58, 51, 1),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
