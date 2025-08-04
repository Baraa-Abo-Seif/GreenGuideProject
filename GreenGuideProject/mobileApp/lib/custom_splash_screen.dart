import 'package:flutter/material.dart';

class CustomSplashScreen extends StatefulWidget {
  final VoidCallback onSplashFinished;
  
  const CustomSplashScreen({
    Key? key,
    required this.onSplashFinished,
  }) : super(key: key);

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _dotsController;
  late AnimationController _backgroundController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;  late Animation<double> _backgroundGradient;
  late Animation<double> _textFade;
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _logoRotation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _backgroundGradient = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _startAnimations();
  }  void _startAnimations() async {
    // Start background animation first
    _backgroundController.forward();
    
    // Slight delay before logo animation
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    
    // Start text animation much faster - almost immediately with logo
    await Future.delayed(const Duration(milliseconds: 50));
    _textController.forward();
    
    // Start dots animation
    await Future.delayed(const Duration(milliseconds: 300));
    _dotsController.repeat();
    
    // Wait for total splash duration, then finish
    await Future.delayed(const Duration(milliseconds: 3000));
    widget.onSplashFinished();
  }
  @override
  void dispose() {
    _logoController.dispose();
    _dotsController.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFFCEFFAE),
                    const Color(0xFFB8E99B),
                    _backgroundGradient.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFCEFFAE),
                    const Color(0xFFE8FFD4),
                    _backgroundGradient.value,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating particles background
                ...List.generate(6, (index) => 
                  AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return Positioned(
                        left: (index * 80.0) + (20 * _backgroundGradient.value),
                        top: (index * 120.0) + (30 * _backgroundGradient.value),
                        child: Opacity(
                          opacity: 0.1 * _backgroundGradient.value,
                          child: Transform.rotate(
                            angle: _backgroundGradient.value * (index + 1),
                            child: Container(
                              width: 20 + (index * 5),
                              height: 20 + (index * 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B5335),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo with enhanced effects
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _logoRotation.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoOpacity.value,                                child: Container(
                                  width: 320,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                      child: Image.asset(
                                        'images/logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Enhanced Loading Dots with bounce effect
                      AnimatedBuilder(
                        animation: _dotsController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final animationValue = _dotsController.value;
                              final delay = index * 0.2;
                              final bounceValue = ((animationValue + delay) % 1.0);
                              final scale = 1.0 + (0.5 * (1 - (bounceValue - 0.5).abs() * 2).clamp(0.0, 1.0));
                              
                              return Transform.scale(
                                scale: scale,                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  height: 14,
                                  width: 14,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.lerp(
                                          const Color(0xFF5B5335),
                                          const Color(0xFF91835B),
                                          bounceValue,
                                        )!,
                                        Color.lerp(
                                          const Color(0xFF91835B),
                                          const Color(0xFF5B5335),
                                          bounceValue,
                                        )!,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                        // Enhanced App name with fade animation only
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _textFade,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF5B5335),
                                  Color(0xFF91835B),
                                  Color(0xFF5B5335),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'Green Guide',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Subtitle with fade animation
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _textFade,
                            child: Text(
                              'Your Sustainable Journey Begins',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF5B5335).withOpacity(0.8),
                                letterSpacing: 1.2,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
