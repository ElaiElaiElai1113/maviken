import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/create_account.dart';
import 'package:maviken/components/text_field_bar.dart';
import 'package:maviken/components/button_button.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/Login';
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        color: const Color(0xFFFCF7E6),
        child: Center(
          child: Container(
            height: screenHeight * .5,
            width: screenWidth * .4,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 236, 223, 196),
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  width: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Image(
                      image: AssetImage('../lib/assets/mavikenlogo1.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                textFieldBar(
                    'Email', const Icon(Icons.person), _emailController),
                textFieldBarPass('Password', const Icon(Icons.lock),
                    _passwordController, true),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final email = _emailController.text;
                          final password = _passwordController.text;

                          try {
                            final response = await supabase.auth
                                .signInWithPassword(
                                    email: email, password: password);

                            if (response.user != null) {
                              Navigator.pushReplacementNamed(
                                  context, DashBoard.routeName);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid email or password'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Invalid Credentials! Please try again'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Colors.black87,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        bottomButton(screenWidth, context, "Forgot Password",
                            CreateAccount.routeName),
                        bottomButton(screenWidth, context, "Sign-up",
                            CreateAccount.routeName),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
