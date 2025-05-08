import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/create_account_page.dart';
import 'sentiment_tabs_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentiment Analysis',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/sentimentTabs': (context) => const SentimentTabsPage(),
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Welcome", style: TextStyle(fontSize: 30)),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = true;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRemembered = prefs.getBool('rememberMe') ?? false;
    
    if (isRemembered) {
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');
      
      if (savedEmail != null && savedPassword != null) {
        // Auto-fill the credentials
        setState(() {
          usernameController.text = savedEmail;
          passwordController.text = savedPassword;
        });
        
        // Auto-login
        Future.delayed(Duration(milliseconds: 500), () {
          login(context);
        });
      }
    }
  }

  void login(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    if (usernameController.text == savedEmail && passwordController.text == savedPassword) {
      // Save remember me preference
      await prefs.setBool('rememberMe', rememberMe);
      
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SentimentTabsPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sign In", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username or email')),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (val) {
                    setState(() {
                      rememberMe = val ?? true;
                    });
                  }
                ),
                const Text("Remember me"),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text("Forgot password?"))
              ],
            ),
            ElevatedButton(
              onPressed: () {
                login(context);
              },
              child: const Text("Login"),
            ),
            SizedBox(height: 16),
            // Add the Create Account button here
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateAccountPage()),
                );
              },
              child: const Text("Don't have an account? Create one"),
            )
          ],
        ),
      ),
    );
  }
}

class SentimentTabs extends StatefulWidget {
  const SentimentTabs({super.key});

  @override
  _SentimentTabsState createState() => _SentimentTabsState();
}

class _SentimentTabsState extends State<SentimentTabs> {
  File? image;
  final TextEditingController textController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sentiment Analysis"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Text"),
              Tab(text: "Image"),
              Tab(text: "Link"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(controller: textController, decoration: InputDecoration(labelText: "Enter text")),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: () {}, child: Text("Confirm"))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(onPressed: pickImage, child: Text("Upload Image")),
                  if (image != null) Image.file(image!, height: 100),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: () {}, child: Text("Confirm"))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(controller: linkController, decoration: InputDecoration(labelText: "Enter link")),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: () {}, child: Text("Confirm"))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
