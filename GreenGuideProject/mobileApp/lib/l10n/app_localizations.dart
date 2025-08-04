import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale);

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];
  // Properties for all your strings
  String get appTitle;
  String get back;
  String get generalSettings;
  String get language;
  String get setLanguage;
  String get fontSize;
  String get careNotifications;
  String get allowAccess;
  String get customApplication;
  String get subscriptions;
  String get disconnectToSmartGlass;
  String get careChange;
  String get clearCache;
  String get support;
  String get encourageUs;
  String get help;
  String get contactUs;
  String get logOut;
  String get disconnectedSuccessfully;
  String get reset;
  String get loading;
  String get signIn;
  String get logIn;
  String get register;
  String get helloSignUpContinue;
  String get email;
  String get password;
  String get forgotPassword;
  String get dontHaveAccount;  
  String get home;
  String get glass;
  String get qna;
  String get welcome;
  String get loginToAccount;
  String get enterEmail;
  String get enterPassword;
  String get emailRequired;
  String get passwordRequired;
  String get errorMessage;
  String get languageEnglish;
  String get languageArabic;
  String get decreaseFontSize;
  String get increaseFontSize;
  String get typeYourQuestion;
  String get enterEmailAddress;
  String get type;
  String get gender;
  String get phoneNumber;  String get unexpectedError;
  String get questionUpdated;  String get to;
  // Main Screen Strings
  String get suggestions;
  String get articlesAndRecommendations;
  String get waterConsumption;
  String get quickGuide;
  String get generalAdvice;
  
  // Forgot Password Strings
  String get forgotPasswordTitle;
  String get enterEmailAssociated;
  String get sendResetLink;
  String get rememberPassword;
  String get login;
  String get passwordResetTitle;
  String get passwordResetMessage;
  String get done;
  String get invalidEmail;
  
  // Sign Up Strings
  String get signupTitle;
  String get fullName;
  String get enterFullName;
  String get nameRequired;
  String get selectYourType;
  String get confirmationPasswordRequired;
  String get passwordsDoNotMatch;
  String get passwordCriteria;
  String get termsAndConditions;
  String get acceptTermsConditions;
  String get alreadyHaveAccount;
  
  // Edit Profile Strings
  String get editProfileTitle;
  String get save;
  String get aboutYou;
  String get fullNameLabel;
  String get male;
  String get female;
  String get dateOfBirth;
  String get selectDate;
  String get addressInformation;
  String get country;
  String get selectCountry;
  String get city;
  String get selectCity;  String get updateSuccessful;
  String get firstName;
  String get lastName;
  String get enterFirstName;
  String get enterLastName;
  String get thisFieldRequired;
  String get phoneNumberRequired;
  String get selectCountryTitle;
    // Other Screen Titles
  String get waterConsumptionTitle;
  String get chooseCareTitle;
  String get generalAdviceTitle;
  String get articlesRecommendationsTitle;
    // Question Screen Strings
  String greeting(String userName);
  String get chooseQuestion;
  String get questionsHeader;
    // User Type Strings
  String get farmerType;
  String get nutritionType;
  String get athleteType;
  String get homeGardensType;
  
  // QR Screen Strings
  String get scanQRCode;
  String get glassesSetup;
  String get scanQRDescription;
  String get glassesConnected;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  // Lookup logic based on the locale
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ar': return AppLocalizationsAr();
    default: return AppLocalizationsEn();
  }
}  /// English translations
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get appTitle => 'Green Guide';
  @override
  String get back => 'Back';
  @override
  String get generalSettings => 'General Settings';
  @override
  String get language => 'Language';
  @override
  String get setLanguage => 'Set Language';
  @override
  String get fontSize => 'Font Size';
  @override
  String get careNotifications => 'Care Notifications';
  @override
  String get allowAccess => 'Allow Access';
  @override
  String get customApplication => 'Custom Application';
  @override
  String get subscriptions => 'Subscriptions';
  @override
  String get disconnectToSmartGlass => 'Disconnect to Smart Glass';
  @override
  String get careChange => 'Care Change';
  @override
  String get clearCache => 'Clear Cache';
  @override
  String get support => 'Support';
  @override
  String get encourageUs => 'Encourage Us';
  @override
  String get help => 'Help';
  @override
  String get contactUs => 'Contact Us';
  @override
  String get logOut => 'Log Out';
  @override
  String get disconnectedSuccessfully => 'Disconnected successfully';
  @override
  String get reset => 'Reset';
  @override
  String get loading => 'Loading';
  @override 
  String get signIn => 'Sign In';
  @override
  String get logIn => 'Login';
  @override
  String get register => ' Sign Up';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get dontHaveAccount => 'Don\'t have an account?';  
  @override
  String get home => 'Home';
  @override
  String get glass => 'Glass';
  @override
  String get qna => 'Q & A';
  @override
  String get welcome => 'Welcome';
  @override
  String get loginToAccount => 'Login to your account';
  @override
  String get enterEmail => 'Enter your Email';
  @override
  String get enterPassword => 'Enter your password';
  @override
  String get emailRequired => 'Email is required';
  @override
  String get passwordRequired => 'Password is required';
  @override
  String get errorMessage => 'Something went wrong. Please try again.';
  @override
  String get languageEnglish => 'English';  @override
  String get languageArabic => 'العربية';
  @override
  String get decreaseFontSize => 'Decrease font size';
  @override
  String get increaseFontSize => 'Increase font size';
  @override
  String get typeYourQuestion => 'Type a question or choose below';
  @override
  String get enterEmailAddress => 'Enter email address';
  @override
  String get type => 'Type';
  @override
  String get gender => 'Gender';
  @override
  String get phoneNumber => 'Phone number';  @override
  String get unexpectedError => 'An unexpected error occurred.';  @override
  String get questionUpdated => 'Question updated';
  @override
  String get to => 'to';
  
  // Main Screen Strings
  @override
  String get suggestions => 'suggestions that may help';
  @override
  String get articlesAndRecommendations => 'Articles and Recommendations';
  @override
  String get waterConsumption => 'Water Consumption';
  @override
  String get quickGuide => 'Quick Guide';
  @override
  String get generalAdvice => 'General Advice';
  
  // Forgot Password Strings
  @override
  String get forgotPasswordTitle => 'Forgot Password?';
  @override
  String get enterEmailAssociated => 'Enter the email associated with your account';
  @override
  String get sendResetLink => 'Send Reset Link';
  @override
  String get rememberPassword => 'Remember your password?';
  @override
  String get login => 'Login';
  @override
  String get passwordResetTitle => 'Your password has been reset';
  @override
  String get passwordResetMessage => 'You\'ll shortly receive an email with a code to setup a new password.';
  @override
  String get done => 'Done';
  @override
  String get invalidEmail => 'Enter a valid email';
  
  // Sign Up Strings
  @override
  String get signupTitle => 'Create Account';
  @override
  String get fullName => 'Full Name';
  @override
  String get enterFullName => 'Enter your full name';
  @override
  String get nameRequired => 'Name is required';
  @override
  String get selectYourType => 'Select your type';
  @override
  String get confirmationPasswordRequired => 'Confirmation password is required';
  @override
  String get passwordsDoNotMatch => 'The password and confirmation password do not match';
  @override
  String get passwordCriteria => 'Password must be at least 8 characters, include one uppercase letter and one number';
  @override
  String get termsAndConditions => 'By creating an account, you agree to our Terms & Conditions';
  @override
  String get acceptTermsConditions => 'Please accept the terms and conditions';
  @override
  String get alreadyHaveAccount => 'Already have an account?';
  @override
  String get helloSignUpContinue => 'Hello there, sign up to continue!';
  
  // Edit Profile Strings
  @override
  String get editProfileTitle => 'Edit Profile';
  @override
  String get save => 'Save';
  @override
  String get aboutYou => 'About You';
  @override
  String get fullNameLabel => 'Full Name';
  @override
  String get firstName => 'First Name';
  @override
  String get lastName => 'Last Name';
  @override
  String get male => 'Male';
  @override
  String get female => 'Female';
  @override
  String get dateOfBirth => 'Birth Date';
  @override
  String get selectDate => 'Select Date';
  @override
  String get addressInformation => 'Address Information';
  @override
  String get country => 'Country';
  @override
  String get selectCountry => 'Select Country';
  @override
  String get city => 'City';
  @override
  String get selectCity => 'Select City';  @override
  String get updateSuccessful => 'Profile Updated Successfully';
  @override
  String get enterFirstName => 'Enter your first name';
  @override
  String get enterLastName => 'Enter your last name';
  @override
  String get thisFieldRequired => 'This field is required';
  @override
  String get phoneNumberRequired => 'Phone number is required';
  @override
  String get selectCountryTitle => 'Select Country';
    // Other Screen Titles
  @override
  String get waterConsumptionTitle => 'Water Consumption';
  @override
  String get chooseCareTitle => 'Choose Care';
  @override
  String get generalAdviceTitle => 'General Advice';
  @override
  String get articlesRecommendationsTitle => 'Articles & Recommendations';
  
  // Question Screen Strings  @override
  String greeting(String userName) => 'Hi $userName';
  @override
  String get chooseQuestion => 'Choose a Question';
  @override
  String get questionsHeader => 'Questions';
  
  // User Type Strings  @override
  String get farmerType => 'Farmer';
  @override
  String get nutritionType => 'Nutrition';
  @override
  String get athleteType => 'Athlete';
  @override
  String get homeGardensType => 'Home Gardens';
  
  // QR Screen Strings
  @override
  String get scanQRCode => 'Scan QR Code';
  @override
  String get glassesSetup => 'Glasses Setup';
  @override
  String get scanQRDescription => 'Scan the QR code on the glasses to begin managing your patient\'s care.';
  @override
  String get glassesConnected => 'Your Glasses are Connected';
}

/// Arabic translations
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr() : super('ar');

  // Add Arabic translations here
  @override
  String get appTitle => 'الدليل الأخضر';
  @override
  String get back => 'رجوع';
  @override
  String get generalSettings => 'الإعدادات العامة';
  @override
  String get language => 'اللغة';
  @override
  String get setLanguage => 'تعيين اللغة';
  @override
  String get fontSize => 'حجم الخط';
  @override
  String get careNotifications => 'إشعارات العناية';
  @override
  String get allowAccess => 'السماح بالوصول';
  @override
  String get customApplication => 'تطبيق مخصص';
  @override
  String get subscriptions => 'الاشتراكات';
  @override
  String get disconnectToSmartGlass => 'قطع الاتصال بالنظارة الذكية';
  @override
  String get careChange => 'تغيير الرعاية';
  @override
  String get clearCache => 'مسح ذاكرة التخزين المؤقت';
  @override
  String get support => 'الدعم';
  @override
  String get encourageUs => 'شجعنا';
  @override
  String get help => 'المساعدة';
  @override
  String get contactUs => 'اتصل بنا';
  @override
  String get logOut => 'تسجيل الخروج';
  @override
  String get disconnectedSuccessfully => 'تم قطع الاتصال بنجاح';
  @override
  String get reset => 'إعادة تعيين';
  @override
  String get loading => 'جارٍ التحميل';
  @override 
  String get signIn => 'سجل الدخول';
  @override
  String get logIn => 'تسجيل الدخول';
  @override
  String get register => ' تسجيل';
  @override
  String get email => 'البريد الإلكتروني';
  @override
  String get password => 'كلمة المرور';
  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';  
  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';  
  @override
  String get home => 'الرئيسية';
  @override
  String get glass => 'النظارة';
  @override
  String get qna => 'أسئلة وأجوبة';
  @override
  String get welcome => 'اهلا بك';
  @override
  String get loginToAccount => 'تسجيل الدخول إلى حسابك';
  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';
  @override
  String get enterPassword => 'أدخل كلمة المرور';
  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';
  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';
  @override
  String get errorMessage => 'حدث خطأ. يرجى المحاولة مرة أخرى.';
  @override
  String get languageEnglish => 'English';  
  @override
  String get languageArabic => 'العربية';
  @override
  String get decreaseFontSize => 'تصغير حجم الخط';
  @override
  String get increaseFontSize => 'تكبير حجم الخط';
  @override
  String get typeYourQuestion => 'اكتب سؤال أو اختر في الاسفل';
  @override
  String get enterEmailAddress => 'أدخل عنوان البريد الإلكتروني';
  @override
  String get type => 'النوع';
  @override
  String get gender => 'الجنس';
  @override
  String get phoneNumber => 'رقم الهاتف';  @override
  String get unexpectedError => 'حدث خطأ غير متوقع.';  @override
  String get questionUpdated => 'تم تحديث السؤال';
  @override
  String get to => 'إلى';
  
  // Main Screen Strings
  @override
  String get suggestions => 'اقتراحات قد تساعدك';
  @override
  String get articlesAndRecommendations => 'المقالات والتوصيات';
  @override
  String get waterConsumption => 'استهلاك المياه';
  @override
  String get quickGuide => 'الدليل السريع';
  @override
  String get generalAdvice => 'نصائح عامة';
  
  // Forgot Password Strings
  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور؟';
  @override
  String get enterEmailAssociated => 'أدخل البريد الإلكتروني المرتبط بحسابك';
  @override
  String get sendResetLink => 'إرسال رابط إعادة الضبط';
  @override
  String get rememberPassword => 'تذكرت كلمة المرور؟';
  @override
  String get login => 'تسجيل الدخول';
  @override
  String get passwordResetTitle => 'تم إعادة تعيين كلمة المرور';
  @override
  String get passwordResetMessage => 'سوف تتلقى قريبًا رسالة بريد إلكتروني تحتوي على رمز لإعداد كلمة مرور جديدة.';
  @override
  String get done => 'تم';
  @override
  String get invalidEmail => 'أدخل بريد إلكتروني صالح';
  
  // Sign Up Strings
  @override
  String get signupTitle => 'إنشاء حساب';
  @override
  String get fullName => 'الاسم الكامل';
  @override
  String get enterFullName => 'أدخل اسمك الكامل';
  @override
  String get nameRequired => 'الاسم مطلوب';
  @override
  String get selectYourType => 'حدد النوع الخاص بك';
  @override
  String get confirmationPasswordRequired => 'تأكيد كلمة المرور مطلوب';
  @override
  String get passwordsDoNotMatch => 'كلمة المرور وتأكيدها غير متطابقين';
  @override
  String get passwordCriteria => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل، وتتضمن حرفًا كبيرًا ورقمًا واحدًا';
  @override
  String get termsAndConditions => 'من خلال إنشاء حساب، فإنك توافق على الشروط والأحكام الخاصة بنا';
  @override
  String get acceptTermsConditions => 'يرجى قبول الشروط والأحكام';
  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';
  @override
  String get helloSignUpContinue => 'مرحباً بك، قم بالتسجيل للاستمرار!';
  
  // Edit Profile Strings
  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';
  @override
  String get save => 'حفظ';
  @override
  String get aboutYou => 'معلومات عنك';
  @override
  String get fullNameLabel => 'الاسم الكامل';
  @override
  String get firstName => 'الاسم الأول';
  @override
  String get lastName => 'الاسم الأخير';
  @override
  String get male => 'ذكر';
  @override
  String get female => 'أنثى';
  @override
  String get dateOfBirth => 'تاريخ الميلاد';
  @override
  String get selectDate => 'اختر التاريخ';
  @override
  String get addressInformation => 'معلومات العنوان';
  @override
  String get country => 'الدولة';
  @override
  String get selectCountry => 'اختر الدولة';
  @override
  String get city => 'المدينة';
  @override
  String get selectCity => 'اختر المدينة';  @override
  String get updateSuccessful => 'تم تحديث الملف الشخصي بنجاح';
  @override
  String get enterFirstName => 'أدخل اسمك الأول';
  @override
  String get enterLastName => 'أدخل اسمك الأخير';
  @override
  String get thisFieldRequired => 'هذا الحقل مطلوب';
  @override
  String get phoneNumberRequired => 'رقم الهاتف مطلوب';
  @override
  String get selectCountryTitle => 'اختر الدولة';
    // Other Screen Titles
  @override
  String get waterConsumptionTitle => 'استهلاك المياه';
  @override
  String get chooseCareTitle => 'اختر العناية';
  @override
  String get generalAdviceTitle => 'نصائح عامة';
  @override
  String get articlesRecommendationsTitle => 'مقالات وتوصيات';
  
  // Question Screen Strings
  @override
  String greeting(String userName) => 'مرحبا $userName';
  @override
  String get chooseQuestion => 'اختر سؤالاً';
  @override
  String get questionsHeader => 'الأسئلة';
  
  // User Type Strings  @override
  String get farmerType => 'مزارع';
  @override
  String get nutritionType => 'تغذية';
  @override
  String get athleteType => 'رياضي';
  @override
  String get homeGardensType => 'حدائق منزلية';
  
  // QR Screen Strings
  @override
  String get scanQRCode => 'مسح رمز QR';
  @override
  String get glassesSetup => 'إعداد النظارات';
  @override
  String get scanQRDescription => 'امسح رمز QR الموجود على النظارات للبدء في إدارة رعاية مريضك.';
  @override
  String get glassesConnected => 'تم توصيل النظارات الخاصة بك';
}
