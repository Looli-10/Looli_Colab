import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/AuthScreens/RegOrLogin.dart';

class Lll extends StatefulWidget {
  const Lll({super.key});

  @override
  State<Lll> createState() => _LllState();
}

class _LllState extends State<Lll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[looliFirst, looliSecond],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // First image
              Positioned(
                top: 50.h,
                left: 10.w,
                child: Image.asset(
                  'assets/images/live.png',
                  width: 230.w,
                ),
              ),
              // Second image
              Positioned(
                top: 200.h,
                left: 80.w,
                child: Image.asset(
                  'assets/images/love.png',
                  width: 230.w,
                ),
              ),
              // Third image
              Positioned(
                top: 350.h,
                left: 150.w,
                child: Image.asset(
                  'assets/images/loop.png',
                  width: 230.w,
                ),
              ),
              // Continue Button with RTL transition
              Positioned(
                bottom: 150.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const LoginPage(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0); // Start from right
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          final offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: looliFourth,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 80.w,
                      vertical: 20.h,
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: looliThird,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      fontFamily: 'Poppins',
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
