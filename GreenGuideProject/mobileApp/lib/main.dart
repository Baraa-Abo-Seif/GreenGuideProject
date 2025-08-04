import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';
import 'login.dart';
import 'bottom_nav_screen.dart'; 
import 'api_service.dart';
import 'font_provider.dart';
import 'locale_provider.dart';
import 'custom_splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'GP2',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      supportedLocales: const [Locale('ar'), Locale('en')], // Arabic first for priority
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: GoogleFonts.readexProTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          fontSizeFactor: fontSizeProvider.fontSizeFactor,
        ),
        iconTheme: IconThemeData(
          size: 24 * fontSizeProvider.fontSizeFactor,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true, // Center titles for better RTL support
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          // Apply font scale to the entire app including widgets that
          // read directly from MediaQuery
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(fontSizeProvider.fontSizeFactor),
          ),
          child: child!,
        );
      },
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _showCustomSplash = true; // Show custom splash first

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
  String? accessToken = await _storage.read(key: 'access_token');
  String? refreshToken = await _storage.read(key: 'refresh_token');

  if (accessToken != null && accessToken.isNotEmpty) {
    bool isValid = await ApiService.checkToken(accessToken);

    if (isValid) {
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
      return;
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      String? newAccessToken = await ApiService.refreshAccessToken(refreshToken);

      if (newAccessToken != null) {
        await _storage.write(key: 'access_token', value: newAccessToken);
        setState(() {
          _isLoggedIn = true;
          _isLoading = false;
        });
        return;
      }
    }
  }

  // If all fails, not logged in
  setState(() {
    _isLoggedIn = false;
    _isLoading = false;
  });
}



  @override
  Widget build(BuildContext context) {
    // Show custom splash screen first
    if (_showCustomSplash) {
      return CustomSplashScreen(
        onSplashFinished: () {
          setState(() {
            _showCustomSplash = false;
          });
        },
      );
    }
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isLoggedIn ? const BottomNavScreen() : const LoginScreen();
  }
}
