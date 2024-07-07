import 'package:flutter/material.dart';
import 'forgetpass_ser.dart'; // Correct import for ForgotPasswordService

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB75CFF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Enter your email to receive a password reset link.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                buildEmailField(),
                SizedBox(height: 20),
                if (errorMessage != null) buildErrorMessage(),
                SizedBox(height: 20),
                buildSendEmailButton(),
                SizedBox(height: 20),
                buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
      ),
    );
  }

  Widget buildErrorMessage() {
    return Text(
      errorMessage!,
      style: TextStyle(color: Colors.red),
      textAlign: TextAlign.center,
    );
  }

  Widget buildSendEmailButton() {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color.fromARGB(255, 160, 93, 241),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.white, // Outline color
                  width: 0.5, // Outline width
                ),
              ),
              child: MaterialButton(
                onPressed: sendPasswordResetEmail,
                minWidth: 200.0,
                height: 45.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  'Send Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildCancelButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Color.fromARGB(255, 160, 93, 241),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white, // Outline color
            width: 0.5, // Outline width
          ),
        ),
        child: MaterialButton(
          onPressed: () {
            Navigator.pop(context); // Close current screen
          },
          minWidth: 200.0,
          height: 45.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendPasswordResetEmail() async {
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await ForgotPasswordService.sendPasswordResetEmail(email);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Password Reset Email Sent'),
          content: Text('Please check your email for the password reset link.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close forgot password screen
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage =
            'Error sending password reset email. Please try again later.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
