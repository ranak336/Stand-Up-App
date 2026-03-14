import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // if (!email.endsWith('@misa.gov.sa')) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Email must end with @misa.gov.sa')));
    //   return;
    // }

    try {
      // 1. Sign in user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      String uid = userCredential.user!.uid;

      // 2. Get user document
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(uid).get();

      String name;
      if (userDoc.exists) {
        name = userDoc['name'];
      } else {
        // if user exists in Auth but not in Firestore, create doc
        name = email.split('@')[0];
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. Navigate to HomePage
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(userName: name)));
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No account found with this email.")),
          );
          return;
        }

        if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Incorrect password.")),
          );
          return;
        }

        if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid email format.")),
          );
          return;
        }

        if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email or password is incorrect.")),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Please try again.")),
      );
    }
  }

  // -------- Forgot Password Function --------
  void _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first")),
      );
      return;
    }

    // if (!email.endsWith('@misa.gov.sa')) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Email must end with @misa.gov.sa")),
    //   );
    //   return;
    // }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent. Check your inbox."),
        ),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No account found with this email.")),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send reset email.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(height: 120, color: const Color(0xFF386641)),
              const SizedBox(height: 40),
              const LogoDots(),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF386641)),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    CustomInputField(
                        label: "Email",
                        hint: "you@misa.gov.sa",
                        icon: Icons.email_outlined,
                        controller: emailController),
                    CustomInputField(
                        label: "Password",
                        hint: "******",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: passwordController),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: _resetPassword,
                          child: const Text("Forgot Password?",
                              style: TextStyle(
                                  color: Color(0xFF386641),
                                  fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF386641),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            );
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Color(0xFF386641),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

// --- Custom Widgets (Shared with SignUpPage) ---
class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const CustomInputField(
      {super.key,
        required this.label,
        required this.hint,
        required this.icon,
        required this.controller,
        this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ]),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              hintText: hint,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }
}

class LogoDots extends StatelessWidget {
  const LogoDots({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircleAvatar(radius: 12, backgroundColor: Color(0xFF386641)),
      const SizedBox(width: 8),
      CircleAvatar(
          radius: 8, backgroundColor: const Color(0xFF386641).withOpacity(0.8)),
      const SizedBox(width: 8),
      CircleAvatar(
          radius: 6, backgroundColor: const Color(0xFF386641).withOpacity(0.6)),
    ]);
  }
}
