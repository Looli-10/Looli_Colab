import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looli_app/Constants/helper/Gradient.dart';
import 'package:looli_app/Constants/helper/Label.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/AuthScreens/RegOrLogin.dart';
import 'package:looli_app/Screens/HomePage.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _createAccount()async {
    String mail = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (mail.isEmpty ||password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: looliThird,
        ),
      );
      return;
    }    else{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email:mail , password: password)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful!'),
            backgroundColor: Colors.deepOrangeAccent,
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => const Homepage(),
        ));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check your email and password again!'),
            backgroundColor: looliThird,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                Center(
                  child: Image.asset(
                    'assets/icons/LooliText.png',
                    width: 80.w,
                    height: 80.h,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Confirm your account',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 30.h),
                // Name field
                // Email field
                FieldLabel(label: 'Email'),
                SizedBox(height: 6.h),
                GradientTextField(
                  label: 'Enter your Email',
                  controller: _emailController,
                ),

                // Password field
                FieldLabel(label: 'Password'),
                SizedBox(height: 6.h),
                GradientTextField(
                  label: 'Enter your Password',
                  obscureText: true,
                  controller: _passwordController,
                ),
                SizedBox(height: 10.h),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    onPressed: _createAccount,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 6,
                      backgroundColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [looliFirst, looliSecond],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: looliFourth,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ));
                  },
                  child: Text(
                    'Not a Loolian ?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      color: looliThird,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}