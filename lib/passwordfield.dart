import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final FormFieldValidator<String>? validator; // Add validator parameter

  PasswordField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.validator, // Add validator parameter
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      obscureText: !_showPassword,
      validator: widget.validator, // Pass validator to TextFormField
    );
  }
}
