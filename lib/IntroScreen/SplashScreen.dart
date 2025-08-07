import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/IntroScreen/LLL.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _textSlide;

  bool _showWell = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.95, curve: Curves.easeOut),
      ),
    );


    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _showWell = false);
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const Lll(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideTween = Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            final fadeTween = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeIn));

            final scaleTween = Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOutBack));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(slideTween),
                child: ScaleTransition(
                  scale: animation.drive(scaleTween),
                  child: child,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWell() {
    return Positioned(
      bottom: 120.h,
      child: AnimatedOpacity(
        opacity: _showWell ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: Container(
          width: 80.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.deepOrange.shade100,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SlideTransition(
          position: _logoSlide,
          child: Image.asset(
            'assets/icons/LoolIcon.png',
            width: 80.w,
            height: 80.h,
          ),
        ),
        SizedBox(height: 10.h),
        SlideTransition(
          position: _textSlide,
          child: Text(
            'Looli',
            style: TextStyle(
              fontSize: 20.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: looliFourth,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: looliFifth,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildWell(),
            _buildLogoAndText(),
          ],
        ),
      ),
    );
  }
}
