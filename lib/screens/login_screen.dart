import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/register_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/my_button.dart';
import 'package:chat_app/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void signIn() async {
    try {
      String res = await AuthService().signInUser(
          email: _emailController.text, password: _passwordController.text);
      if (res == "success") {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomeScreen()));
      } 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7C81AD),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: MediaQuery.of(context).size.width > 700
                ? const EdgeInsets.only(top: 20)
                : EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width > 700
                      ? MediaQuery.of(context).size.width * 0.2
                      : MediaQuery.of(context).size.width * 0.6,
                ),
                MyTextField(
                  hintText: 'Please enter your email address',
                  controller: _emailController,
                ),
                MyTextField(
                  hintText: 'Please enter your password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                MyButton(
                  onTap: signIn,
                  text: 'Login',
                ),
                Padding(
                  padding: MediaQuery.of(context).size.width > 700
                      ? const EdgeInsets.symmetric(vertical: 20)
                      : EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "You are not a member yet? ",
                        style: TextStyle(
                            color: Color(0xFF2E4374),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
