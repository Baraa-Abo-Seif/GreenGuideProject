import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';
import 'login.dart';
import 'api_service.dart';
import 'font_provider.dart';
import 'locale_provider.dart';
import 'bottom_nav_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {  
  int _selectedCareType = 2; // Default to Nutrition
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    _loadCurrentCareType();
  }
  
  Future<void> _loadCurrentCareType() async {
    String? accessToken = await _storage.read(key: 'access_token');

    if (accessToken == null || accessToken.isEmpty) {
      print('No access token found');
      return;
    }

    try {
      final currentUser = await ApiService.updateUserTypeID(
        accessToken: accessToken,
        typeID: null, 
        question: null,
      );

      if (mounted &&
          currentUser.containsKey('user') &&
          currentUser['user'].containsKey('typeID') &&
          currentUser['user']['typeID'] != null) {
        setState(() {
          _selectedCareType = currentUser['user']['typeID'];
        });
      }
    } catch (e) {
      print('Failed to load user type: $e');
    }
  }


  void logout() async {
    // Read the stored refresh token
    final refreshToken = await _storage.read(key: 'refresh_token');

    if (refreshToken != null) {
      try {
        // Call your API to invalidate the refresh token on the server
        await ApiService.logout(refreshToken);
      } catch (e) {
        // Optional: handle/log errors—but still proceed to clear local tokens
        print('API logout failed: $e');
      }
    }

    // Clear tokens locally
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    // Navigate back to login
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void changeCare(int typeID) async {
    // Get the access token
    String? accessToken = await _storage.read(key: 'access_token');
    
    try {
      if (accessToken == null || accessToken.isEmpty) {
        print('Access token is missing');
        return;
      }

      final response = await ApiService.updateUserTypeID(
        accessToken: accessToken,
        typeID: typeID,
        question: 'Changed via settings',
      );

      if (!mounted) return;

      if (response.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Care preference updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedCareType = typeID;
        });

        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavScreen()),
        (route) => false,
      );

      }
    } 
    catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
    }

  void disconnect() async {
    // Read the stored refresh token
    final refreshToken = await _storage.read(key: 'refresh_token');

    if (refreshToken != null) {
      try {
        // Call your API to invalidate the refresh token on the server
        await ApiService.disconnectGlass(refreshToken);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.disconnectedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Optional: handle/log errors—but still proceed to clear local tokens
        print('API logout failed: $e');
      }
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(206, 255, 174, 1),      
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppBar(
            backgroundColor: const Color.fromRGBO(206, 255, 174, 1),
            automaticallyImplyLeading: false,
            leading: Row(
              children: [                IconButton(
                  icon: const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(Icons.arrow_back),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  AppLocalizations.of(context)!.back,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            leadingWidth: 120, // Adjust this value to accommodate the text
            actions: [
              const Padding(
                padding: EdgeInsets.only(right: 16.0, left: 16.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/profile.png'), 
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [            
          _buildSettingsCard(
            title: AppLocalizations.of(context)!.generalSettings,
            items: [
              _buildLanguageDropdown(context),
              const Divider(thickness: 1, color: Color(0xFF000000)),
              _buildFontSizeSettings(context),
              _buildSettingItem('assets/Bell_pin.png', AppLocalizations.of(context)!.careNotifications),
              const Divider(thickness: 1, color: Color(0xFF000000)),
              _buildSettingItem('assets/padlock.png', AppLocalizations.of(context)!.allowAccess),
             
            ],
          ),
          const SizedBox(height: 16),   

          _buildSettingsCard(
            title: AppLocalizations.of(context)!.customApplication,
            items: [
              _buildSettingItem('assets/chield_check.png', AppLocalizations.of(context)!.subscriptions),
              const Divider(thickness: 1, color: Color(0xFF000000)),
              _buildSettingItem('assets/Glass.png', AppLocalizations.of(context)!.disconnectToSmartGlass, disconnect),
              const Divider(thickness: 1, color: Color(0xFF000000)),
              _buildCareTypeDropdown(context),
              const Divider(thickness: 1, color: Color(0xFF000000)),
              _buildSettingItem('assets/folder_del.png', AppLocalizations.of(context)!.clearCache),
            ],
          ),
          const SizedBox(height: 16),          _buildSettingsCard(
            title: AppLocalizations.of(context)!.support,
            items: [
              _buildSettingItem('assets/thumb_up.png', AppLocalizations.of(context)!.encourageUs),
              const Divider(thickness: 1, color: Color(0xFF000000)),
              _buildSettingItem('assets/question.png', AppLocalizations.of(context)!.help),
              const Divider(thickness: 1, color: Color(0xFF000000)),
              _buildSettingItem('assets/chat.png', AppLocalizations.of(context)!.contactUs),
              const Divider(thickness: 1, color: Color(0xFF000000)),
              _buildSettingItem('assets/logout.png', AppLocalizations.of(context)!.logOut, () => logout()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> items}) {
    return Card(
      color: const Color.fromRGBO(255,255,255, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [              Text(
              title,
              style: GoogleFonts.readexPro(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: const Color.fromARGB(255, 42, 40, 29),
              ),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }    Widget _buildSettingItem(String iconPath, String text, [VoidCallback? onTap]) {
    final content = Column(
      children: [
        Row(
          // Let the row follow the current text direction (RTL or LTR)
          children: [
            // Only force LTR on the icon itself
            Directionality(
              textDirection: TextDirection.ltr,
              child: Image.asset(
                iconPath,
                width: 50,
                height: 50,
                color: const Color.fromRGBO(51, 54, 63, 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 22,
                  color: const Color.fromRGBO(91, 83, 53, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
      ],
    );

    // If onTap is provided, wrap with InkWell. Otherwise return plain content.
    return onTap != null
        ? InkWell(onTap: onTap, child: content)
        : content;
  }  Widget _buildCareTypeDropdown(BuildContext context) {
    // Map care type ID to their localized display names
    final Map<int, String> careTypes = {
      1: AppLocalizations.of(context)!.farmerType,
      2: AppLocalizations.of(context)!.nutritionType,
      3: AppLocalizations.of(context)!.athleteType,
    };
      return Column(
      children: [
        Row(
          // Allow row to follow natural text direction
          children: [
            // Only the icon needs LTR direction
            Directionality(
              textDirection: TextDirection.ltr,
              child: Image.asset(
                'assets/directions.png',
                width: 50,
                height: 50,
                color: const Color.fromRGBO(51, 54, 63, 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.careChange,
                style: const TextStyle(
                  fontSize: 22,
                  color: Color.fromRGBO(91, 83, 53, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedCareType,                  icon: const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(Icons.arrow_drop_down, size: 20),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(91, 83, 53, 1),
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      changeCare(newValue);
                    }
                  },
                  items: careTypes.entries.map<DropdownMenuItem<int>>((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
    Widget _buildLanguageDropdown(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    // Map of locale codes to their native language names
    final Map<String, String> languages = {
      'en': 'English',
      'ar': 'العربية',
    };
      return Column(
      children: [
        Row(
          // Allow row to follow natural text direction
          children: [
            // Only the icon needs LTR direction
            Directionality(
              textDirection: TextDirection.ltr,
              child: Image.asset(
                'assets/globe.png',
                width: 50,
                height: 50,
                color: const Color.fromRGBO(51, 54, 63, 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.setLanguage,
                style: const TextStyle(
                  fontSize: 22,
                  color: Color.fromRGBO(91, 83, 53, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: localeProvider.locale.languageCode,                  
                  icon: const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(Icons.arrow_drop_down, size: 20),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(91, 83, 53, 1),
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      localeProvider.setLocale(Locale(newValue));
                      Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => BottomNavScreen()),
                      (route) => false,
                    );
                    }
                  },
                  items: languages.entries.map<DropdownMenuItem<String>>((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,                      
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFontSizeSettings(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
      return Column(
      children: [        Row(
          // Allow row to follow natural text direction
          children: [
            // Only the icon needs LTR direction
            Directionality(
              textDirection: TextDirection.ltr,
              child: Image.asset(
                'assets/document.png',
                width: 50,
                height: 50,
                color: const Color(0xFF33363F),
              ),
            ),
            const SizedBox(width: 12),            
            Expanded(              
              child: Text(
                AppLocalizations.of(context)!.fontSize,
                style: TextStyle(
                  fontSize: 22,
                  color: const Color.fromRGBO(91, 83, 53, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),            IconButton(
                onPressed: fontProvider.decreaseFontSize,
                icon: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(Icons.text_decrease, size: 28),
                ),
                tooltip: AppLocalizations.of(context)!.decreaseFontSize,
              ),
              Text(
                '${(fontProvider.fontSizeFactor * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),                IconButton(
                onPressed: fontProvider.increaseFontSize,
                icon: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(Icons.text_increase, size: 28),
                ),
                tooltip: AppLocalizations.of(context)!.increaseFontSize,
              ),
       
          ],
        ),
        
        const Divider(thickness: 1, color: Color(0xFF000000)),      ],
    );
  }
}
