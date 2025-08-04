import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gp2/signup.dart';
import 'package:gp2/forgot_password.dart';
import 'package:gp2/bottom_nav_screen.dart';
import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'l10n/app_localizations.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 1)
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Added validator functions outside the widget tree
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailRequired;
    }
    return null;
  }
  
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.passwordRequired;
    }
    return null;
  }

  double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSize * (screenWidth / 375); // 375 is base width for design
  }

  Future<void> _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      final response = await ApiService.login(email, password);

      if (!mounted) return;
      final storage = FlutterSecureStorage();

      final accessToken = response['access_token'];
      final refreshToken = response['refresh_token'];

      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavScreen()),
        (route) => false,
      );
    } on HttpException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).padding;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight - padding.top - padding.bottom,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // Added this line
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr, // Force left-to-right layout
                  child: Container(
                  width: screenWidth,
                  height: getResponsiveHeight(context, 25),
                  color: const Color.fromRGBO(206, 255, 174, 1),
                  alignment: Alignment.bottomCenter,
                  child: Center(
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                      alignment: Alignment.bottomLeft,
                      child: Image.asset(
                        'images/fnan1.png',
                        width: getResponsiveWidth(context, 33),
                        height: getResponsiveHeight(context, 20),
                        fit: BoxFit.contain,
                      ),
                      ),
                      Container(
                        child: Image.asset(
                        'images/logo.png',
                        width: getResponsiveWidth(context, 60),
                        height: getResponsiveHeight(context, 20),
                        fit: BoxFit.fitWidth,
                      ),
                      ),
                    ],
                    ),
                  ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getResponsiveWidth(context, 6),
                    vertical: getResponsiveHeight(context, 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getResponsiveHeight(context, 2)),
                      Text(
                        AppLocalizations.of(context)!.welcome,
                        style: GoogleFonts.inder(
                          fontSize: getResponsiveFontSize(context, 36),
                          color: const Color.fromRGBO(42, 40, 29, 1),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),       
                      ),
                      SizedBox(height: getResponsiveHeight(context, 0.5)),
                      Text(
                        AppLocalizations.of(context)!.loginToAccount,
                        style: GoogleFonts.inder(
                          fontSize: getResponsiveFontSize(context, 16),
                          color: const Color.fromRGBO(126, 131, 137, 1),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: getResponsiveHeight(context, 8)),
                      Text(
                        AppLocalizations.of(context)!.email,
                        style: TextStyle(
                          color: const Color.fromRGBO(76, 65, 39, 1),
                          fontSize: getResponsiveFontSize(context, 15),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: getResponsiveHeight(context, 1)),
                      
                      // Enhanced TextFormField for email
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          validator: _validateEmail,
                          style: TextStyle(fontSize: getResponsiveFontSize(context, 16)),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterEmail,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: const Color.fromRGBO(126, 131, 137, 1),
                              size: getResponsiveFontSize(context, 20),
                            ),
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: getResponsiveFontSize(context, 12),
                            ),
                            hintStyle: TextStyle(
                              color: const Color.fromRGBO(158, 158, 158, 1),
                              fontSize: getResponsiveFontSize(context, 16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide(
                                color: const Color.fromRGBO(230, 230, 230, 1),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide(
                                color: const Color.fromRGBO(230, 230, 230, 1),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide(
                                color: const Color.fromRGBO(76, 65, 39, 1),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: getResponsiveWidth(context, 4),
                              vertical: getResponsiveHeight(context, 1.8),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: getResponsiveHeight(context, 3)),
                      Text(
                        AppLocalizations.of(context)!.password,
                        style: TextStyle(
                          color: const Color.fromRGBO(76, 65, 39, 1),
                          fontSize: getResponsiveFontSize(context, 15),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: getResponsiveHeight(context, 1)),
                      
                      // Enhanced TextFormField for password
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          validator: _validatePassword,
                          obscureText: _obscurePassword,
                          style: TextStyle(fontSize: getResponsiveFontSize(context, 16)),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterPassword,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: const Color.fromRGBO(126, 131, 137, 1),
                              size: getResponsiveFontSize(context, 20),
                            ),
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: getResponsiveFontSize(context, 12),
                            ),
                            hintStyle: TextStyle(
                              color: const Color.fromRGBO(158, 158, 158, 1),
                              fontSize: getResponsiveFontSize(context, 16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide(
                                color: const Color.fromRGBO(230, 230, 230, 1),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide(
                                color: const Color.fromRGBO(230, 230, 230, 1),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide(
                                color: const Color.fromRGBO(76, 65, 39, 1),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: getResponsiveWidth(context, 4),
                              vertical: getResponsiveHeight(context, 1.8),
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color.fromRGBO(126, 131, 137, 1),
                                  size: getResponsiveFontSize(context, 20),
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                        ),
                      ),
                  
                      SizedBox(height: getResponsiveHeight(context, 3)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const ForgotPasswordScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 250),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child:
                          // Text for "Forgot Password?" with responsive font size
                          
                           Text(
                            AppLocalizations.of(context)!.forgotPassword,
                            style: TextStyle(
                              color: Color.fromRGBO(76, 65, 39, 1),
                              fontSize: getResponsiveFontSize(context, 15),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: getResponsiveHeight(context, 10)),
                      
                      Center(
                        child: SizedBox(
                          width: getResponsiveWidth(context, 80),
                          height: getResponsiveHeight(context, 5),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(76, 65, 39, 1),
                              padding: EdgeInsets.symmetric(
                                vertical: getResponsiveHeight(context, 1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(39),
                              ),
                              disabledBackgroundColor: Color.fromRGBO(230, 235, 246, 1),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: getResponsiveHeight(context, 3),
                                    width: getResponsiveHeight(context, 3),
                                    child: const CircularProgressIndicator(color: Colors.white),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.logIn,
                                    style: GoogleFonts.inder(
                                      fontSize: getResponsiveFontSize(context, 15),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                          ), 
                        ),
                      ),

                      SizedBox(height: getResponsiveHeight(context, 4)),
                      
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.dontHaveAccount,
                              style: TextStyle(
                                color: const Color.fromRGBO(196, 196, 196, 1),
                                fontSize: getResponsiveFontSize(context, 14),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => const SignupScreen(),
                                    transitionsBuilder: (_, animation, __, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        )),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.register,
                                style: TextStyle(
                                  color: Color.fromRGBO(76, 65, 39, 1),
                                  fontSize: getResponsiveFontSize(context, 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: getResponsiveHeight(context, 2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}