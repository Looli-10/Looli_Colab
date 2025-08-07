import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:looli_app/Constants/helper/Gradient.dart';
import 'package:looli_app/Constants/helper/Label.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/AuthScreens/Login.dart';
import 'package:looli_app/Screens/HomePage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _createAccount() async {
    String name = _nameController.text.trim();
    String mail = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (name.isEmpty ||mail.isEmpty ||password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar( 
          content: Text('Please fill in all fields'),
          backgroundColor: looliThird,
        ),
      );
      return;
    }
    else{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email:mail , password: password)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Created Successfully!'),
            backgroundColor: Colors.deepOrangeAccent,
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => const AuthLogin(),
        ));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: looliThird,
          ),
        );
      });
    }
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
                  'Create your account',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: looliFourth,
                  ),
                ),
                SizedBox(height: 30.h),
                // Name field
                FieldLabel(label: 'Name'),
                SizedBox(height: 6.h),
                GradientTextField(
                  label: 'Enter your Name',
                  controller: _nameController,
                ),
    
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
                          'Create Account',
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
                      builder: (context) => const AuthLogin(),
                    ));
                  },
                  child: Text(
                    'Already a Loolian ?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      color: looliFourth,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                // Divider & continue
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'or',
                        style: TextStyle(fontFamily: 'Poppins',color: looliFourth),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 15.h),
                Text(
                  'Continue with',
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins',color: looliFourth),
                ),
                SizedBox(height: 10.h),
    
                // Google Button
                GestureDetector(
                  onTap: ()async {
                    bool isLoggedIn = await login();
                    if (isLoggedIn) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Homepage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login Failed'),
                          backgroundColor: looliThird,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [looliFirst, looliSecond],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: looliSixth,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/Google.png',
                          width: 30.w,
                          height: 30.h,
                        ),
                      ),
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
Future<bool> login() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return false; // User cancelled the sign-in
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return true; // Sign-in successful
    } catch (e) {
      print('Error during Google sign-in: $e');
      return false; // Sign-in failed
    }
  }
}