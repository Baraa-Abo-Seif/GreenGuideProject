import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'api_service.dart';
import 'login.dart';
import 'dart:io';

// Responsive utility functions
double getResponsiveHeight(double height, BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  // Base height for iPhone 14 Pro (852)
  double baseHeight = 852.0;
  return (height / baseHeight) * screenHeight;
}

double getResponsiveWidth(double width, BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  // Base width for iPhone 14 Pro (393)
  double baseWidth = 393.0;
  return (width / baseWidth) * screenWidth;
}

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _questionController = TextEditingController();
  List<String> questions = [];
  bool isLoading = true;
  int? selectedQuestionIndex;
  @override
  void initState() {
    super.initState();
    loadSelectedQuestion();
    fetchQuestions();
  }

  Future<void> loadSelectedQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedQuestionIndex = prefs.getInt('selected_question_index');
    });
  }

  Future<void> saveSelectedQuestion(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_question_index', index);
  }

  Future<void> fetchQuestions() async {
    final accessToken = await storage.read(key: 'access_token');
    final refreshToken = await storage.read(key: 'refresh_token');

    if (accessToken == null || refreshToken == null) {
      redirectToLogin();
      return;
    }

    try {
      String lang = Localizations.localeOf(context).languageCode;
      final data = await ApiService.getQuestionsByUserType(accessToken, lang);
      setState(() {
        questions = List<String>.from(
          (data['questions'] as List).map((q) => q['text']),
        );
        isLoading = false;
      });
    } on HttpException catch (e) {
      if (e.message.contains('expired')) {
        final newAccessToken = await ApiService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await storage.write(key: 'access_token', value: newAccessToken);
          fetchQuestions(); // Retry after refreshing
        } else {
          redirectToLogin();
        }
      } else {
        redirectToLogin();
      }
    } catch (_) {
      redirectToLogin();
    }
  }
  Future<void> sendCustomQuestion() async {
    final questionText = _questionController.text.trim();
    if (questionText.isEmpty) return;

    final accessToken = await storage.read(key: 'access_token');
    final refreshToken = await storage.read(key: 'refresh_token');

    if (accessToken == null || refreshToken == null) {
      redirectToLogin();
      return;
    }

    try {
      await ApiService.updateUserQuestion(
        accessToken: accessToken,
        question: questionText,
      );
        // Clear the text field and reset selection
      _questionController.clear();
      setState(() {
        selectedQuestionIndex = null;
      });
      
      // Clear saved selection
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_question_index');
      
    } on HttpException catch (e) {
      if (e.message.contains('expired')) {
        final newAccessToken = await ApiService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await storage.write(key: 'access_token', value: newAccessToken);
          sendCustomQuestion(); // Retry with new token
        } else {
          redirectToLogin();
        }
      } else {
        redirectToLogin();
      }
    } catch (_) {
      redirectToLogin();
    }
  }

  Future<void> updateQuestionWithRetry(String questionText, int index) async {
    final accessToken = await storage.read(key: 'access_token');
    final refreshToken = await storage.read(key: 'refresh_token');

    if (accessToken == null || refreshToken == null) {
      redirectToLogin();
      return;
    }    try {
      await ApiService.updateUserQuestion(
        accessToken: accessToken,
        question: questionText,
      );
        // Update the selected question index
      setState(() {
        selectedQuestionIndex = index;
      });
      
      // Save to persistent storage
      await saveSelectedQuestion(index);
      
    } on HttpException catch (e) {
      if (e.message.contains('expired')) {
        final newAccessToken = await ApiService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await storage.write(key: 'access_token', value: newAccessToken);
          updateQuestionWithRetry(questionText, index); // Retry with new token
        } else {
          redirectToLogin();
        }
      } else {
        redirectToLogin();
      }
    } catch (_) {
      redirectToLogin();
    }
  }
  void redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(206, 255, 174, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,                  children: [    

                    // Top Row
                    Row(
                      textDirection: TextDirection.ltr, // Fix RTL layout issue
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        // Logo on the left
                        SizedBox(
                          width: getResponsiveWidth(120, context),
                          height: getResponsiveHeight(70, context),
                          child: Image.asset(
                              'images/logo.png',
                              fit: BoxFit.contain,
                            ),                        
                            ),
                        // Profile avatar on the right
                        CircleAvatar(
                          radius: getResponsiveWidth(30, context),
                          backgroundImage: AssetImage('assets/profile.png'),
                        ),
                      ],                    ),
                    const SizedBox(height: 20),                      
                    // Text input field with LTR direction to prevent reversal
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)?.typeYourQuestion,
                          hintStyle: const TextStyle(
                            color: Color.fromRGBO(145, 149, 142, 1),
                            fontFamily: 'Poppins',
                          ),
                          suffixIcon: GestureDetector(
                            onTap: sendCustomQuestion,
                            child: const Icon(Icons.send),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onSubmitted: (_) => sendCustomQuestion(),
                      ),
                    ),

                      
                    const SizedBox(height: 20),
                    
                    // Questions List
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [                            // Title for questions list
                            Text(
                              AppLocalizations.of(context)?.chooseQuestion ?? 'Choose Question',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(42, 40, 29, 1),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Questions ListView
                            Expanded(
                              child: ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedQuestionIndex == index;
                            return GestureDetector(
                              onTap: () => updateQuestionWithRetry(questions[index], index),
                              child: Card(
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                color: isSelected 
                                    ? const Color.fromRGBO(206, 255, 174, 0.8) // Light green for selected
                                    : const Color.fromRGBO(240, 255, 230, 1), // Default color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      questions[index],
                                      textAlign: TextAlign.center,                                      
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: const Color.fromARGB(255, 91, 83, 53), // Default text color
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),                                ),
                              ),
                            );
                          },
                        ),
                            ),
                          ],
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
