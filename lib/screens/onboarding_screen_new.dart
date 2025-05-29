import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom painters for onboarding animations
class ChartGridPainter extends CustomPainter {
  final double animValue;
  
  ChartGridPainter(this.animValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    // Draw grid lines
    for (int i = 0; i < 6; i++) {
      double y = size.height * (i / 5.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    
    for (int i = 0; i < 6; i++) {
      double x = size.width * (i / 5.0);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    
    // Draw animated chart line
    final Paint chartPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
      
    final Path path = Path();
    
    for (int i = 0; i < 20; i++) {
      double x = size.width * (i / 19.0);
      double normalY = sin((i / 19.0 + animValue) * 4 * pi) * 0.4 + 0.5;
      double y = size.height * (1.0 - normalY);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, chartPaint);
  }
  
  @override
  bool shouldRepaint(ChartGridPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}

class ShieldPainter extends CustomPainter {
  final double animValue;
  
  ShieldPainter(this.animValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint shieldPaint = Paint()
      ..color = Colors.purple.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
      
    final Paint glowPaint = Paint()
      ..color = Colors.purple.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      
    // Draw shield shape
    final Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width * 0.9, size.height * 0.2);
    path.quadraticBezierTo(
      size.width, size.height * 0.5,
      size.width * 0.5, size.height
    );
    path.quadraticBezierTo(
      0, size.height * 0.5,
      size.width * 0.1, size.height * 0.2
    );
    path.close();
    
    // Animated glow
    final double breathe = (sin(animValue * 2 * pi) + 1) / 2;
    glowPaint.strokeWidth = 6.0 + (breathe * 8.0);
    
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, shieldPaint);
  }
  
  @override
  bool shouldRepaint(ShieldPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _backgroundAnimationController;
  late AnimationController _contentAnimationController;

  // Dynamic onboarding data
  final List<Map<String, String>> _pages = [
    {
      'title': 'Smart Financial Management',
      'subtitle': 'Take control of your finances with powerful tracking tools',
      'button': 'Get Started',
      'footer': 'Already have an account? Sign in',
    },
    {
      'title': 'Watch Your Savings Grow',
      'subtitle': 'Set goals and track your progress with beautiful visualizations',
      'button': 'Next',
      'footer': '',
    },
    {
      'title': 'Insightful Analytics',
      'subtitle': 'Understand your spending patterns with AI-powered insights',
      'button': 'Next',
      'footer': '',
    },
    {
      'title': 'Secure and Private',
      'subtitle': 'Your financial data is protected with bank-level security',
      'button': 'Get Started',
      'footer': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20000),
    )..repeat();
    
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage == _pages.length - 1) {
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      _contentAnimationController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _contentAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = const Color(0xFF4866FF);
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 72, 102, 255),
                      Color.fromARGB(255, 94, 124, 255),
                      Color.fromARGB(255, 123, 148, 255),
                    ],
                    stops: [
                      0.0 + (_backgroundAnimationController.value * 0.2),
                      0.5 + (_backgroundAnimationController.value * 0.1),
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Floating financial icons (animated)
          ...List.generate(10, (index) {
            final random = index * 0.1;
            return Positioned(
              top: size.height * (0.1 + random * 0.8),
              left: size.width * ((index % 2 == 0) ? 0.1 + random * 0.3 : 0.6 + random * 0.3),
              child: AnimatedBuilder(
                animation: _backgroundAnimationController,
                builder: (context, child) {
                  final offset = sin(_backgroundAnimationController.value * 2 * 3.14 + index) * 10;
                  return Transform.translate(
                    offset: Offset(offset, offset * 0.5),
                    child: Opacity(
                      opacity: 0.1 + random * 0.2,
                      child: Icon(
                        _getFinancialIcon(index),
                        size: 20 + random * 30,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/signin'),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _contentAnimationController.reset();
                      _contentAnimationController.forward();
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SafeArea(
                          bottom: true,
                          minimum: const EdgeInsets.only(bottom: 16),
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Icon
                            FadeIn(
                              duration: const Duration(milliseconds: 800),
                              child: SizedBox(
                                height: size.height * 0.35,
                                child: AnimatedBuilder(
                                  animation: _backgroundAnimationController,
                                  builder: (context, child) {
                                    return _buildAnimatedVisual(index, context, size);
                                  },
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Title
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              delay: const Duration(milliseconds: 300),
                              from: 30,
                              child: Text(
                                _pages[index]['title']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Subtitle
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              delay: const Duration(milliseconds: 500),
                              from: 30,
                              child: Text(
                                _pages[index]['subtitle']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Page indicators
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              delay: const Duration(milliseconds: 700),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _pages.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentPage == i ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _currentPage == i
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: _currentPage == i
                                          ? [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.3),
                                                blurRadius: 8,
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Next button
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              delay: const Duration(milliseconds: 900),
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _onNext,
                                  child: Text(
                                    index == _pages.length - 1 ? 'Get Started' : 'Next',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Footer text (Sign in link)
                            if (_pages[index]['footer']!.isNotEmpty)
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 1100),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                                  child: TextButton(
                                    onPressed: () => Navigator.pushReplacementNamed(context, '/signin'),
                                    child: Text(
                                      _pages[index]['footer']!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get financial icons
  IconData _getFinancialIcon(int index) {
    final icons = [
      Icons.account_balance_wallet,
      Icons.monetization_on,
      Icons.savings,
      Icons.credit_card,
      Icons.currency_exchange,
      Icons.attach_money,
      Icons.pie_chart,
      Icons.trending_up,
      Icons.account_balance,
      Icons.payments,
    ];
    return icons[index % icons.length];
  }
  
  // Build unique animated visuals for each onboarding page
  Widget _buildAnimatedVisual(int index, BuildContext context, Size size) {
    final animValue = _backgroundAnimationController.value;
    final breathValue = (sin(animValue * 2 * pi) + 1) / 2;
    
    switch (index) {
      case 0: // Smart Financial Management
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating ring
            Transform.rotate(
              angle: animValue * 2 * pi,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.amber.withOpacity(0.1),
                      Colors.amber.withOpacity(0.5),
                      Colors.amber.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                ),
              ),
            ),
            // Middle pulsing ring
            Transform.scale(
              scale: 0.8 + (breathValue * 0.1),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white24, width: 8),
                ),
              ),
            ),
            // Floating coins
            ...List.generate(6, (i) {
              return Transform.translate(
                offset: Offset(
                  sin((animValue * 2 * pi) + (i * pi / 3)) * 60,
                  cos((animValue * 2 * pi) + (i * pi / 3)) * 60,
                ),
                child: Transform.rotate(
                  angle: animValue * 4 * pi,
                  child: Icon(
                    Icons.monetization_on,
                    size: 25 + (i % 3) * 5.0,
                    color: Colors.amber,
                  ),
                ),
              );
            }),
            // Center wallet icon
            Icon(
              Icons.account_balance_wallet,
              size: 70,
              color: Colors.white,
            ),
          ],
        );
        
      case 1: // Watch Your Savings Grow
        return Stack(
          alignment: Alignment.center,
          children: [
            // Growth circle with animated size
            Transform.scale(
              scale: 0.7 + (breathValue * 0.3),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.15),
                ),
              ),
            ),
            // Growth bars
            ...List.generate(5, (i) {
              final barHeight = 20.0 + (i * 15) + (i == 4 ? (30 * breathValue) : 0);
              final xOffset = (i - 2) * 30.0;
              return Positioned(
                bottom: 70,
                left: size.width * 0.5 - 15 + xOffset,
                child: Container(
                  width: 20,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.4 + (i * 0.1)),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                ),
              );
            }),
            // Animated coin stack
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, -20 - (10 * breathValue)),
                  child: Icon(Icons.monetization_on, size: 40, color: Colors.amber),
                ),
                Transform.translate(
                  offset: Offset(0, -15 - (5 * breathValue)),
                  child: Icon(Icons.monetization_on, size: 40, color: Colors.amber.shade600),
                ),
                Icon(Icons.monetization_on, size: 40, color: Colors.amber.shade800),
              ],
            ),
          ],
        );
        
      case 2: // Insightful Analytics
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background chart grid
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CustomPaint(
                painter: ChartGridPainter(animValue),
              ),
            ),
            // Floating data points
            ...List.generate(8, (i) {
              final angle = (i / 8.0) * 2 * pi;
              final radius = 70.0 + (sin(angle * 3 + (animValue * 2 * pi)) * 20.0);
              return Positioned(
                left: 100.0 + cos(angle) * radius,
                top: 100.0 + sin(angle) * radius,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Central analytics icon
            Icon(
              Icons.analytics,
              size: 60,
              color: Colors.white,
            ),
          ],
        );
        
      case 3: // Secure and Private
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer security shield
            Transform.scale(
              scale: 0.9 + (breathValue * 0.1),
              child: Container(
                width: 180,
                height: 210,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100).copyWith(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(color: Colors.purple.withOpacity(0.3), width: 2),
                ),
              ),
            ),
            // Center lock icon
            const Icon(
              Icons.lock,
              size: 50,
              color: Colors.white,
            ),
            // Orbiting security elements
            ...List.generate(3, (i) {
              final angle = animValue * 2 * pi + (i * (2 * pi / 3));
              return Transform.translate(
                offset: Offset(
                  cos(angle) * 80.0,
                  sin(angle) * 80.0,
                ),
                child: Icon(
                  [Icons.security, Icons.verified_user, Icons.shield][i],
                  size: 25,
                  color: Colors.white70,
                ),
              );
            }),
          ],
        );
        
      default:
        return Container(); // Fallback
    }
  }
  
  // End of _buildAnimatedVisual method
}
