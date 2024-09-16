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
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile view
            return MobileLoginView(
              emailController: _emailController,
              passwordController: _passwordController,
              supabase: supabase,
            );
          } else {
            // Web view
            return WebLoginView(
              emailController: _emailController,
              passwordController: _passwordController,
              supabase: supabase,
            );
          }
        },
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

@override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return Container(
    height: screenHeight,
    width: screenWidth,
    color: const Color(0xFFFCF7E6),
    child: Center(
      child: Container(
        height: screenHeight * .6,
        width: screenWidth * .8,
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
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: Image(
                  image: AssetImage('../lib/assets/mavikenlogo1.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            textFieldBar('Email', const Icon(Icons.person), emailController),
            textFieldBarPass(
                'Password', const Icon(Icons.lock), passwordController, true),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: screenWidth * .6,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text;
                      final password = passwordController.text;

                      try {
                        final response = await supabase.auth.signInWithPassword(
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
                            content:
                                Text('Invalid Credentials! Please try again'),
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
                        CreateAccount.routeName, 16),
                    bottomButton(screenWidth, context, "Sign-up",
                        CreateAccount.routeName, 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class MobileLoginView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final SupabaseClient supabase;

  const MobileLoginView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.supabase,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      width: screenWidth,
      color: const Color(0xFFFCF7E6),
      child: Center(
        child: Container(
          height: screenHeight * .6,
          width: screenWidth * .8,
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
                width: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: Image(
                    image: AssetImage('../lib/assets/mavikenlogo1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 500,
                width: 500,
                child: Text("MAVIKEN"),
              ),
              textFieldBar('email', const Icon(Icons.person), emailController),
              textFieldBarPass(
                  'password', const Icon(Icons.lock), passwordController, true),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: screenWidth * .6,
                    child: ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text;
                        final password = passwordController.text;

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
                              content:
                                  Text('Invalid Credentials! Please try again'),
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
                      SizedBox(
                        width: 130,
                        height: 50,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: bottomButton(screenWidth, context,
                              "Forgot Password", CreateAccount.routeName, 14),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        height: 50,
                        child: bottomButton(screenWidth, context, "Sign-up",
                            CreateAccount.routeName, 14),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebLoginView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final SupabaseClient supabase;

  const WebLoginView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.supabase,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      width: screenWidth,
      color: const Color(0xFFFCF7E6),
      child: Center(
        child: Container(
          height: screenHeight * .8,
          width: screenWidth * .4,
          decoration: const BoxDecoration(
            color: Colors.grey,
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
              const Text('Welcome to',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    height: 0.3,
                    shadows: <Shadow>[
                      Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3.0,
                          color: Colors.black)
                    ],
                  )),
              const Text('MAVIKEN',
                  style: TextStyle(
                      fontSize: 84,
                      shadows: <Shadow>[
                        Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 3.0,
                            color: Colors.black)
                      ],
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w900,
                      height: 0.3)),
              textFieldBar('email', const Icon(Icons.person), emailController),
              textFieldBarPass(
                  'password', const Icon(Icons.lock), passwordController, true),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: screenWidth * .2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text;
                        final password = passwordController.text;

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
                              content:
                                  Text('Invalid Credentials! Please try again'),
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
                          CreateAccount.routeName, 16),
                      bottomButton(screenWidth, context, "Sign-up",
                          CreateAccount.routeName, 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
