import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/signup.dart';
import 'ExpensePage.dart';
//import 'signup.dart';
//import 'passwordfield.dart';
import 'forgetpassword.dart';
//import 'auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBZiX847EQ-O59RD0z-EoorrJ2r7qnOuok",
            authDomain: "expensetracker-d16b0.firebaseapp.com",
            projectId: "expensetracker-d16b0",
            storageBucket: "expensetracker-d16b0.appspot.com",
            messagingSenderId: "359072885397",
            appId: "1:359072885397:web:6ff2dccbd9832a74d4c99c"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/main': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/expense': (context) => ExpenseTrackerPage(),
        });
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;
  int loginAttempts = 0;
  final int maxLoginAttempts = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB75CFF), // Set the background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 30),
              Text(
                'Expense Tracker',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                  height: 10), // Adjusted size to move title closer to image
              Center(
                child: Image.asset(
                  'assets/expense.png',
                  height: 200, // Adjusted size
                  width: 200, // Adjusted size
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Log in to your account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              buildEmailField(),
              SizedBox(height: 10),
              buildPasswordField(),
              SizedBox(height: 10),
              if (errorMessage != null) buildErrorMessage(),
              SizedBox(height: 10),
              buildLoginButton(),
              SizedBox(height: 10),
              buildSignupOption(),
              buildForgotPasswordOption(),
            ],
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

  Widget buildPasswordField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: togglePasswordVisibility,
        ),
      ),
      obscureText: !isPasswordVisible,
    );
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Widget buildErrorMessage() {
    return Text(
      errorMessage!,
      style: TextStyle(color: Colors.red),
      textAlign: TextAlign.center,
    );
  }

  Widget buildLoginButton() {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color.fromARGB(
                    255, 160, 93, 241), // Darker color for the button
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
                onPressed: loginAttempts >= maxLoginAttempts ? null : signIn,
                minWidth: 200.0,
                height: 45.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildSignupOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("New User?"),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: Text('Create Account', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget buildForgotPasswordOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
            );
          },
          child:
              Text('Forgot Password?', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Future<void> signIn() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (!validateInputs(email, password)) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => ExpenseTrackerPage()), // Adjust as needed
      );
    } on FirebaseAuthException catch (e) {
      handleLoginError(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please fill out all fields';
      });
      return false;
    }
    return true;
  }

  void handleLoginError(FirebaseAuthException e) {
    setState(() {
      errorMessage = 'Please check your credentials and try again';
      loginAttempts++;
      if (loginAttempts >= maxLoginAttempts) {
        errorMessage = 'Too many login attempts. Please try again later.';
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
