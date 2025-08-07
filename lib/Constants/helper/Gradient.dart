import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';

class GradientTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextEditingController controller;

  const GradientTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
  });

  @override
  State<GradientTextField> createState() => _GradientTextFieldState();
}

class _GradientTextFieldState extends State<GradientTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: _hasFocus
            ? const LinearGradient(colors: [looliFirst, looliSecond])
            : null,
      ),
      padding: EdgeInsets.all(_hasFocus ? 2 : 1),
      child: Container(
        decoration: BoxDecoration(
          color: looliSixth,
          borderRadius: BorderRadius.circular(10.r),
          border: _hasFocus ? null : Border.all(color: looliSixth),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 20.h,
            ),
            hintText: widget.label,
            hintStyle: TextStyle(
              color: looliSeventh,
              fontSize: 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
