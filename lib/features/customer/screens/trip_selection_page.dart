import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/systemVarible.dart';
import '../../../core/utils/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import '../../../core/functions/GelocatorFun.dart';
import 'local_trip_map_page.dart';

class TripSelectionPage extends StatefulWidget {
  const TripSelectionPage({Key? key}) : super(key: key);

  @override
  State<TripSelectionPage> createState() => _TripSelectionPageState();
}

class _TripSelectionPageState extends State<TripSelectionPage> {
  final List<String> _features = [
    "رحلات آمنة ومريحة مع أفضل المرشدين السياحيين",
    "اكتشف أجمل المعالم السياحية في مدينتك",
    "تجربة سفر فريدة مع مرافق متخصص",
    "رحلات مخصصة حسب اهتماماتك",
  ];

  int _currentFeatureIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFeatureAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFeatureAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentFeatureIndex = (_currentFeatureIndex + 1) % _features.length;
      });
    });
  }

  Future<void> _handleLocalTripSelection() async {
    try {
      // استخدام الدالة الجديدة لتحديد الموقع
      Position position = await Gelocatorfun.getCurrentPosition();

      // انتقل إلى صفحة الخريطة مع الموقع
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocalTripMapPage(
            initialPosition: position,
          ),
        ),
      );
    } catch (e) {
      // عرض رسالة خطأ في حالة فشل تحديد الموقع
      _showLocationErrorDialog(e.toString());
    }
  }

  void _showLocationErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'خطأ في تحديد الموقع',
            style: AppTextStyles.h3.copyWith(color: systemColors.error),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'حسناً',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: systemColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: systemColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image at the top
              Image.asset(
                'assets/images/UI/toWharePage.png',
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              // Animated Features Text
              SizedBox(
                height: 80,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _features[_currentFeatureIndex],
                    key: ValueKey<int>(_currentFeatureIndex),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: systemColors.primary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              // Local Trip Button
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      systemColors.primary,
                      systemColors.primary.withOpacity(0.9),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: systemColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleLocalTripSelection,
                    borderRadius: BorderRadius.circular(15),
                    splashColor: Colors.white.withOpacity(0.2),
                    highlightColor: systemColors.primary.withOpacity(0.8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationDot,
                            color: systemColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'رحلة في مدينتي',
                            style: AppTextStyles.buttonLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // External Trip Button
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      systemColors.primaryGoust,
                      systemColors.primaryGoust.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: systemColors.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: systemColors.primary.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // TODO: Handle external trip selection
                    },
                    borderRadius: BorderRadius.circular(15),
                    splashColor: systemColors.primary.withOpacity(0.1),
                    highlightColor: systemColors.primaryGoust.withOpacity(0.2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.map,
                            color: systemColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'رحلة خارجية',
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: systemColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// Custom painter for subtle dotted pattern
class DottedPatternPainter extends CustomPainter {
  final Color color;

  DottedPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotSize = 2.0;

    for (var i = 0.0; i < size.width; i += spacing) {
      for (var j = 0.0; j < size.height; j += spacing) {
        canvas.drawCircle(
          Offset(i, j),
          dotSize,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
