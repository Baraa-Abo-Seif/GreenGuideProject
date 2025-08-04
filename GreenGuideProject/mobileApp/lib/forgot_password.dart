import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'api_service.dart';
import 'login.dart';  // Added import for LoginScreen
import 'l10n/app_localizations.dart'; // Import for localization

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>(); // Added form key
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailFilled = false;

  // Added validator function for email with localization
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailRequired;
    }
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    return null;
  }

  // Add responsive dimensions helper methods
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

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateEmailState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateEmailState);
    _emailController.dispose();
    super.dispose();
  }

  void _updateEmailState() {
    setState(() {
      _isEmailFilled = _emailController.text.isNotEmpty;
    });
  }

  Future<void> _handleForgotPassword() async {
    if (_formKey.currentState!.validate()) { // Validate form before proceeding
      setState(() => _isLoading = true);

      try {
        //final response = await ApiService.forgotPassword(_emailController.text.trim());

        if (!mounted) return;

        // Show the success dialog with new design
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getResponsiveFontSize(context, 24)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(getResponsiveFontSize(context, 24)),
                ),
                width: getResponsiveWidth(context, 80), // 80% of screen width
                padding: EdgeInsets.all(getResponsiveFontSize(context, 24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: getResponsiveWidth(context, 30), // 30% of screen width for the image container
                      height: getResponsiveWidth(context, 30), // Keep it square
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: Center(
                        child: Image.asset(
                          'images/lock-overturning.png',
                          width: getResponsiveWidth(context, 25), // Slightly smaller than container
                          height: getResponsiveWidth(context, 25),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: getResponsiveHeight(context, 2)),
              Text(
                        AppLocalizations.of(context)!.passwordResetTitle,
                        style: GoogleFonts.inder( 
                          fontSize: getResponsiveFontSize(context, 24),
                          fontWeight: FontWeight.w600,
                          color: const Color.fromRGBO(10, 31, 68, 1)
                        ),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: getResponsiveHeight(context, 3)),
                    Text(
                      AppLocalizations.of(context)!.passwordResetMessage,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: getResponsiveFontSize(context, 14),
                        color: const Color.fromRGBO(10, 31, 68, 1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: getResponsiveHeight(context, 3)),                      Container(
                        width: getResponsiveWidth(context, 70), // 70% of screen width
                        height: getResponsiveHeight(context, 6), // Consistent with other buttons
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(getResponsiveFontSize(context, 24)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4E432A).withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E432A),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              vertical: getResponsiveHeight(context, 1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(getResponsiveFontSize(context, 24)),
                            ),
                            alignment: Alignment.center,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.done,
                                  style: GoogleFonts.inder(
                                    fontSize: getResponsiveFontSize(context, 18),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: getResponsiveWidth(context, 2)),
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: getResponsiveFontSize(context, 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } catch (e) {
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
            autovalidateMode: AutovalidateMode.onUserInteraction, 
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: getResponsiveHeight(context, 35),
                  color: const Color(0xFFCEFFAE),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 50),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                    
                      Positioned(
                        left: 30,
                        top: 50, 
                        child: Image.asset(
                          'images/logo.png',
                          height: getResponsiveHeight(context, 8),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 90),
                          child: Image.asset(
                            'images/forgot_person.png',
                            height: getResponsiveHeight(context, 25),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
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
                        AppLocalizations.of(context)!.forgotPasswordTitle,
                        style: GoogleFonts.inder(
                          fontSize: getResponsiveFontSize(context, 36),
                          color: const Color.fromRGBO(42, 40, 29, 1),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: getResponsiveHeight(context, 0.5)),
                      Text(
                        AppLocalizations.of(context)!.enterEmailAssociated,
                        style: GoogleFonts.inder(
                          fontSize: getResponsiveFontSize(context, 16),
                          color: const Color.fromRGBO(126, 131, 137, 1),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: getResponsiveHeight(context, 7)),
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
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),

                      SizedBox(height: getResponsiveHeight(context, 4)),
                      Center(
                        child: SizedBox(
                          width: getResponsiveWidth(context, 80),
                          height: getResponsiveHeight(context, 5),
                          child: ElevatedButton(
                            onPressed: (_isLoading || !_isEmailFilled) ? null : _handleForgotPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEmailFilled 
                                ? const Color(0xFF4C4127)
                                : const Color.fromRGBO(230, 235, 246, 1),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: getResponsiveHeight(context, 1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(39),
                              ),
                              disabledBackgroundColor: const Color(0xFFCAC6BF),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: getResponsiveHeight(context, 3),
                                    width: getResponsiveHeight(context, 3),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.sendResetLink,
                                        style: GoogleFonts.inder(
                                          fontSize: getResponsiveFontSize(context, 16),
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: getResponsiveWidth(context, 2)),
                                      Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: getResponsiveFontSize(context, 18),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: getResponsiveHeight(context, 15)),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.rememberPassword + ' ',
                              style: TextStyle(
                                color: const Color.fromRGBO(196, 196, 196, 1),
                                fontSize: getResponsiveFontSize(context, 14),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: TextStyle(
                                  color: Color(0xFF4E432A),
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