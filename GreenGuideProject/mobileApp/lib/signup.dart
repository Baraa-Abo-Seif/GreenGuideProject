import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gp2/login.dart';
import 'api_service.dart';
import 'dart:io';
import 'l10n/app_localizations.dart'; // Import for localization

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _termsAccepted = false;
  
  // User type selection
  String? _selectedUserType;
  late List<Map<String, dynamic>> _userTypes;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize user types with localized strings
    _userTypes = [
      {'id': 1, 'name': AppLocalizations.of(context)!.farmerType},
      {'id': 2, 'name': AppLocalizations.of(context)!.nutritionType},
      {'id': 3, 'name': AppLocalizations.of(context)!.athleteType},
    ];
  }
  
  // Error message states
  String? _emailError;
  String? _passwordError;
  String? _confirmationError;

  bool _isFormValid = false;

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

  // Email validation pattern
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
  
  // Password validation - at least 8 chars, 1 uppercase, 1 number
  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  
  // Validate email and update error state
  void _validateEmail(String? value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _emailError = AppLocalizations.of(context)!.emailRequired;
      } else if (!_isValidEmail(value)) {
        _emailError = AppLocalizations.of(context)!.invalidEmail;
      } else {
        _emailError = null;
      }
    });
    _checkFormValidity();
  }
  
  // Validate password and update error state
  void _validatePassword(String? password) {
    setState(() {
      if (password == null || password.isEmpty) {
        _passwordError = AppLocalizations.of(context)!.passwordRequired;
      } else if (!_isValidPassword(password)) {
        _passwordError = AppLocalizations.of(context)!.passwordCriteria;
      } else {
        _passwordError = null;
      }
    });
    _checkFormValidity();
  }

  void _checkFormValidity() {
    setState(() {
      _isFormValid =
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _selectedUserType != null &&
        _termsAccepted &&
        _emailError == null &&
        _passwordError == null;
    });
  }

  // Custom widget for displaying error messages
  Widget _buildErrorMessage(String? errorText) {
    return errorText != null
        ? Padding(
            padding: EdgeInsets.only(
              top: getResponsiveHeight(context, 0.5),
              left: getResponsiveWidth(context, 4),
            ),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red,
                fontSize: getResponsiveFontSize(context, 12),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    int userTypeId = int.parse(_selectedUserType!);

    try {

      await ApiService.signup(email, password, userTypeId);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
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
  void initState() {
    super.initState();
    _emailController.addListener(() => _validateEmail(_emailController.text));
    _passwordController.addListener(() => _validatePassword(_passwordController.text));
  }

  @override
  void dispose() {
    _emailController.removeListener(() => _validateEmail(_emailController.text));
    _passwordController.removeListener(() => _validatePassword(_passwordController.text));
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr, // Force left-to-right layout
                  child: Container(
                  width: screenWidth,
                  height: getResponsiveHeight(context, 20),
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
                        height: getResponsiveHeight(context, 20),
                        fit: BoxFit.contain,
                      ),
                      ),
                      Container(
                        child: Image.asset(
                        'images/logo.png',
                        height: getResponsiveHeight(context, 12),
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
                     
                      Text(
                        AppLocalizations.of(context)!.signupTitle,
                        style: GoogleFonts.inder(
                          fontSize: getResponsiveFontSize(context, 36),
                          color: const Color.fromRGBO(66, 66, 66, 1),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: getResponsiveHeight(context, 0.5)),
                      Text(
                        AppLocalizations.of(context)!.helloSignUpContinue,
                        style: GoogleFonts.inder(
                          fontSize: getResponsiveFontSize(context, 16),
                          color: const Color.fromRGBO(126, 131, 137, 1),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: getResponsiveHeight(context, 4)),
                      SizedBox(height: getResponsiveHeight(context, 2)),
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
                          onChanged: (value) {
                            _validateEmail(value);
                          },
                          style: TextStyle(fontSize: getResponsiveFontSize(context, 16)),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterEmailAddress,
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
                      _buildErrorMessage(_emailError),
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
                          obscureText: _obscurePassword,
                          onChanged: (value) {
                            _validatePassword(value);
                          },
                          style: TextStyle(fontSize: getResponsiveFontSize(context, 16)),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterPassword,
                            prefixIcon: Icon(
                              Icons.lock_outline,
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
                      _buildErrorMessage(_passwordError),
                       SizedBox(height: getResponsiveHeight(context, 3)),
                      Text(
                        AppLocalizations.of(context)!.type,
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
                        child: Directionality(
                          textDirection: Directionality.of(context), // Keep app's text direction
                    
                          child: DropdownButtonFormField<String>(
                            value: _selectedUserType,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedUserType = newValue;
                              });
                              _checkFormValidity();
                            },
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 16),
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              hintText: null,
                              hintStyle: null,
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: const Color.fromRGBO(126, 131, 137, 1),
                                size: getResponsiveFontSize(context, 20),
                              ),
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: getResponsiveWidth(context, 4),
                                vertical: getResponsiveHeight(context, 2), // Increased vertical padding
                              ),
                            ),
                            // Use hint widget for better RTL support
                            hint: Container(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                AppLocalizations.of(context)!.selectYourType,
                                style: TextStyle(
                                  color: const Color.fromRGBO(158, 158, 158, 1),
                                  fontSize: getResponsiveFontSize(context, 16),
                                ),
                                textAlign: TextAlign.start,
                                textDirection: Directionality.of(context),
                              ),
                            ),
                            items: _userTypes.map<DropdownMenuItem<String>>((Map<String, dynamic> type) {
                              return DropdownMenuItem<String>(
                                value: type['id'].toString(),
                                child: Container(
                                  width: double.infinity,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    type['name'],
                                    textAlign: TextAlign.start,
                                    textDirection: Directionality.of(context),
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context, 16), // Match hint text size
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            isExpanded: true, // Make dropdown take full width
                            // Add dropdown style settings for better RTL support
                            menuMaxHeight: 300,
                            icon: Icon(Icons.arrow_drop_down, textDirection: Directionality.of(context)),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                      _buildErrorMessage(_confirmationError),
                      const SizedBox(height: 25),
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                              scale: getResponsiveFontSize(context, 15) / 24,
                              child: Checkbox(
                                value: _termsAccepted,
                                onChanged: (bool? value) {
                                  setState(() => _termsAccepted = value ?? false);
                                  _checkFormValidity();
                                },
                                activeColor: Color.fromRGBO(76, 65, 39, 1),
                              ),
                            ),
                          
                          SizedBox(width: getResponsiveWidth(context, 1)),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.termsAndConditions,
                              style: TextStyle(
                                color: Color.fromRGBO(76, 65, 39, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: getResponsiveFontSize(context, 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getResponsiveHeight(context, 3)),
                      Center(
                        child: SizedBox(
                          width: getResponsiveWidth(context, 80),
                          height: getResponsiveHeight(context, 5),
                          child: ElevatedButton(
                            onPressed: _isLoading || !_isFormValid ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading || !_isFormValid
                                ? const Color.fromRGBO(230, 235, 246, 1) // Disabled color
                                : const Color.fromRGBO(76, 65, 39, 1), // Enabled color
                              padding: EdgeInsets.symmetric(
                                vertical: getResponsiveHeight(context, 1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(39),
                              ),
                              disabledBackgroundColor: const Color.fromRGBO(202, 198, 191, 1), // Explicitly set disabled color
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: getResponsiveHeight(context, 3),
                                    width: getResponsiveHeight(context, 3),
                                    child: const CircularProgressIndicator(color: Colors.white),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.register,
                                    style: GoogleFonts.inder(
                                      fontSize: getResponsiveFontSize(context, 15),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: getResponsiveHeight(context, 5)),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.alreadyHaveAccount + " ",
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
                                    pageBuilder: (_, __, ___) => const LoginScreen(),
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
                              child: Text(
                                AppLocalizations.of(context)!.signIn + " ",
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
