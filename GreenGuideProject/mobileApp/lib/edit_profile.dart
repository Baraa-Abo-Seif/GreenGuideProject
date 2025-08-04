import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add for kIsWeb
import 'main_screen.dart';
import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'l10n/app_localizations.dart'; // Import for localization
import 'dart:io';
import 'dart:typed_data'; // For web image handling
import 'profile_image_picker.dart'; // Import our new helper class

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Form controllers
final TextEditingController _firstNameController = TextEditingController();
final TextEditingController _lastNameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();

bool _isLoading = true;

// Image picker
File? _selectedImage;
Uint8List? _webImage; // For web platform

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final storage = const FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');
      if (accessToken != null && accessToken.isNotEmpty) {
        final profile = await ApiService.getUserProfile(accessToken);
        _firstNameController.text = profile['first_name'] ?? '';
        _lastNameController.text = profile['last_name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
      } else {
        // Handle missing token (e.g., show login or error)
      }
    } catch (e) {
      // Handle error (show a message, etc.)
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Form key
  final _formKey = GlobalKey<FormState>();
  
  // Country codes list with flags
  final List<Map<String, dynamic>> _countryCodes = [
    {'code': '+962', 'flag': '🇯🇴', 'name': 'Jordan'},
    {'code': '+970', 'flag': '🇵🇸', 'name': 'Palestine'},
    {'code': '+966', 'flag': '🇸🇦', 'name': 'Saudi Arabia'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+20', 'flag': '🇪🇬', 'name': 'Egypt'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+49', 'flag': '🇩🇪', 'name': 'Germany'},
    {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
  ];
  
  // Selected country code
  Map<String, dynamic> _selectedCountry = {'code': '+962', 'flag': '🇯🇴', 'name': 'Jordan'};
  
  // Selected date
  DateTime? _selectedDate;
  
  // Selected gender
  String? _selectedGender;
  
  // List of genders
  // ignore: unused_element
  List<String> _getGendersList(BuildContext context) {
    return [AppLocalizations.of(context)!.male, AppLocalizations.of(context)!.female];
  }

  // Image picker functionality is now handled by ProfileImagePicker class

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                
                children: [
                  // AppBar with back button and profile images
                  _buildHeader(),
                  const SizedBox(height: 50),
                  // Form fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    // Profile title
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.editProfileTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 20),
                    
                    // First Name field
                    _buildInputLabel(AppLocalizations.of(context)!.firstName),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildTextField(_firstNameController, AppLocalizations.of(context)!.enterFirstName),
                    ),
                    const SizedBox(height: 15),
                    
                    // Last Name field
                    _buildInputLabel(AppLocalizations.of(context)!.lastName),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildTextField(_lastNameController, AppLocalizations.of(context)!.enterLastName),
                    ),
                    const SizedBox(height: 15),
                    
                    // Email field
                    _buildInputLabel(AppLocalizations.of(context)!.email),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildTextField(_emailController, AppLocalizations.of(context)!.enterEmail, keyboardType: TextInputType.emailAddress),
                    ),
                    const SizedBox(height: 15),
                    
                    // Phone Number field
                    _buildInputLabel(AppLocalizations.of(context)!.phoneNumber),
                    _buildPhoneField(),
                    const SizedBox(height: 35),
                    
                    // Birthday and Gender row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          // Birthday field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDateField(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          // Gender field
                          Expanded(
                            child: _buildGenderDropdown(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C4127),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the header with back button and profile images
  Widget _buildHeader() {
    return Directionality(
      textDirection: TextDirection.ltr, // Force LTR for header elements
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 180,
            color: const Color.fromARGB(255, 203, 255, 169),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 42.0, top: 24.0),
              child: Image.asset(
                'images/logo.png',
                height: 85, // smaller height
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Back button - fixed position regardless of locale
          Positioned(
            top: 65,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Circle avatar with profile image - positioned on the right
          Positioned(
            bottom: -50,
            right: 30, // Position from right edge
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundImage: _getProfileImage(),
                ),
                // Pin/edit icon for changing image
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      print('DEBUG: Edit icon tapped'); // Debug print
                      // Use our new helper class instead of _showImageSourceDialog()
                      ProfileImagePicker.showImageSourceBottomSheet(
                        context: context,
                        onImageSelected: (File? image) {
                          setState(() {
                            _selectedImage = image;
                          });
                        },
                        onWebImageSelected: (Uint8List? bytes) {
                          setState(() {
                            _webImage = bytes;
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFE5772E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Build input field label
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: const Color.fromRGBO(76, 65, 39, 1),
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // Build text field
  Widget _buildTextField(
    TextEditingController controller, 
    String hintText, 
    {TextInputType keyboardType = TextInputType.text}
  ) {
    // Get the appropriate icon based on the hint text
    Icon? prefixIcon;
    if (hintText.toLowerCase().contains('email')) {
      prefixIcon = Icon(
        Icons.email_outlined,
        color: const Color.fromRGBO(126, 131, 137, 1),
        size: 20,
      );
    } else if (hintText.toLowerCase().contains('first')) {
      prefixIcon = Icon(
        Icons.person_outline,
        color: const Color.fromRGBO(126, 131, 137, 1),
        size: 20,
      );
    } else if (hintText.toLowerCase().contains('last')) {
      prefixIcon = Icon(
        Icons.badge_outlined,
        color: const Color.fromRGBO(126, 131, 137, 1),
        size: 20,
      );
    }
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        hintStyle: TextStyle(
          color: const Color.fromRGBO(158, 158, 158, 1),
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
          borderSide: BorderSide(
            color: const Color.fromRGBO(230, 230, 230, 1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
          borderSide: BorderSide(
            color: const Color.fromRGBO(230, 230, 230, 1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
          borderSide: BorderSide(
            color: const Color.fromRGBO(76, 65, 39, 1),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.thisFieldRequired;
        }
        return null;
      },
    );
  }  // Build phone field with country code selector
  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Directionality(
        textDirection: TextDirection.ltr, // Force LTR for phone number layout
        child: Row(
          children: [
            // Country code dropdown with flags
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(230, 230, 230, 1)),
                borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCountry['flag'], 
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 8),
                  Text(_selectedCountry['code']),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          SizedBox(width: 10),
          // Phone number input
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.phoneNumber,
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: const Color.fromRGBO(126, 131, 137, 1),
                  size: 20,
                ),
                hintStyle: TextStyle(
                  color: const Color.fromRGBO(158, 158, 158, 1),
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
                  borderSide: BorderSide(
                    color: const Color.fromRGBO(230, 230, 230, 1),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
                  borderSide: BorderSide(
                    color: const Color.fromRGBO(230, 230, 230, 1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
                  borderSide: BorderSide(
                    color: const Color.fromRGBO(76, 65, 39, 1),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.phoneNumberRequired;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
  
  // Build date field
  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(230, 230, 230, 1)),
          borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_outlined,
              color: const Color.fromRGBO(126, 131, 137, 1),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? AppLocalizations.of(context)!.dateOfBirth
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: TextStyle(
                  color: _selectedDate == null 
                      ? const Color.fromRGBO(158, 158, 158, 1) 
                      : Colors.black,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 24,
              color: const Color.fromRGBO(126, 131, 137, 1),
            ),
          ],
        ),
      ),
    );
  }

  // Build gender dropdown
  Widget _buildGenderDropdown() {
    final genders = [
      AppLocalizations.of(context)!.male,
      AppLocalizations.of(context)!.female
    ];
    
    return Container(
      padding: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(230, 230, 230, 1)),
        borderRadius: BorderRadius.circular(12.0), // Decreased from 16.0
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: const Color.fromRGBO(126, 131, 137, 1),
            ),
            hint: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: const Color.fromRGBO(126, 131, 137, 1),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.gender,
                  style: TextStyle(
                    color: const Color.fromRGBO(158, 158, 158, 1),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            value: _selectedGender,
            items: genders.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Show country picker in a bottom sheet for better selection
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.selectCountryTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: _countryCodes.length,
                  itemBuilder: (context, index) {
                    final country = _countryCodes[index];
                    return ListTile(
                      leading: Text(
                        country['flag'], 
                        style: TextStyle(fontSize: 30),
                      ),
                      title: Text(country['name']),
                      subtitle: Text(country['code']),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Handle profile image for both web and mobile platforms
  ImageProvider _getProfileImage() {
    if (kIsWeb && _webImage != null) {
      // For web platform with selected image
      return MemoryImage(_webImage!);
    } else if (!kIsWeb && _selectedImage != null) {
      // For mobile platforms with selected image
      return FileImage(_selectedImage!);
    } else {
      // Default image
      return const AssetImage('images/girl.png');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}