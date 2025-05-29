import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Dynamic onboarding data for logic prep
  final List<Map<String, String>> _pages = [
    {
      'title': 'Smart Spending Starts Here',
      'subtitle': '',
      'image': 'assets/img.png', // Add asset path if you have images
      'button': 'Get Started',
      'footer': 'Already have an account? Sign in',
    },
    {
      'title': 'Earn rewards as you shop at campus stores and save more!',
      'subtitle': '',
      'image': 'assets/img_1.png',
      'button': 'Next',
      'footer': '',
    },
    {
      'title': 'Shop, Earn, Repeat because every purchase counts!',
      'subtitle': '',
      'image': 'assets/img_2.png',
      'button': 'Next',
      'footer': '',
    },
    {
      'title': 'Get access to the best deals inside your campus!',
      'subtitle': '',
      'image': 'assets/img_3.png',
      'button': 'Next',
      'footer': '',
    },
  ];

  void _onNext() {
    if (_currentPage == _pages.length - 1) {
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentPage == _pages.length - 1
              ? 'Onboarding finished!'
              : 'Next page',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_pages[i]['image']!.isNotEmpty)
                          Image.asset(_pages[i]['image']!),
                        SizedBox(height: 36),
                        Text(
                          _pages[i]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_pages[i]['subtitle']!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _pages[i]['subtitle']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4866FF),
                            minimumSize: Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _onNext,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: Text(
                              i == 0
                                  ? 'Get Started'
                                  : (i == _pages.length - 1
                                      ? 'Finish'
                                      : 'Next'),
                              key: ValueKey(i),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (_pages[i]['footer']!.isNotEmpty)
                          TextButton(
                            onPressed:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  '/signin',
                                ),
                            child: Text(_pages[i]['footer']!),
                          ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    _currentPage == index
                                        ? Color(0xFF4866FF)
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                                boxShadow:
                                    _currentPage == index
                                        ? [
                                          BoxShadow(
                                            color: Color(
                                              0xFF4866FF,
                                            ).withOpacity(0.2),
                                            blurRadius: 4,
                                          ),
                                        ]
                                        : [],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: TextButton(
                  onPressed:
                      () => Navigator.pushReplacementNamed(context, '/signin'),
                  child: Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFF4866FF)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
