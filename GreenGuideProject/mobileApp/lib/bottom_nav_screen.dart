import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'qr.dart';
import 'question_screen.dart';
import 'l10n/app_localizations.dart';


class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MainScreen(),
    const QrScreen(),
    const QuestionScreen(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: 
      Directionality(
        textDirection: TextDirection.ltr, // Force left-to-right layout
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.green,
          items: [
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('assets/home.png'),
                size: 24,
              ),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('assets/Glasses.png'),
                size: 24,
              ),
              label: AppLocalizations.of(context)!.glass,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('assets/comment.png'),
                size: 24,
              ),
              label: AppLocalizations.of(context)!.qna,
            ),
          ],
        ),
      ),
     );
  }
}
