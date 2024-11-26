import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/screens/create_account.dart';
import 'package:maviken/components/text_field_bar.dart';
import 'package:maviken/components/button_button.dart';

final _emailController = TextEditingController();
final _passwordController = TextEditingController();
void showForgotPasswordDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Forgot Password'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: 'Enter your email'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  final response =
                      await supabase.auth.resetPasswordForEmail(email);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('An error occurred. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

class LoginScreen extends StatefulWidget {
  static const routeName = '/Login';
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            textFieldBar('Email', const Icon(Icons.person), _emailController),
            textFieldBarPass(
                'Password', const Icon(Icons.lock), _passwordController, true),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: screenWidth * .6,
                  child: ElevatedButton(
                    onPressed: () => loginAction(context),
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
                    forgotPassword(screenWidth, context, "Forgot Password",
                        CreateAccount.routeName, 16, () {
                      showForgotPasswordDialog(context);
                    }),
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
              const SizedBox(
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
                      onPressed: () => loginAction(context),
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
                          child: forgotPassword(
                              screenWidth,
                              context,
                              "Forgot Password",
                              CreateAccount.routeName,
                              14, () {
                            showForgotPasswordDialog(context);
                          }),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        height: 50,
                        child: signUpBottom(screenWidth, context, "Sign-up",
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://plus.unsplash.com/premium_photo-1663040229714-f9fd192358b0?q=80&w=2938&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          height: screenHeight * .8,
          width: screenWidth * .4,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
            borderRadius: const BorderRadius.all(
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
              const AutoSizeText('Welcome to',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    height: 0.5,
                    shadows: <Shadow>[
                      Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3.0,
                          color: Colors.black)
                    ],
                  )),
              const AutoSizeText(
                'MAVIKEN',
                maxLines: 1,
                style: TextStyle(
                    fontSize: 108,
                    shadows: <Shadow>[
                      Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3.0,
                          color: Colors.black)
                    ],
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w900,
                    height: 0.5),
              ),
              Column(
                children: [
                  textFieldBar(
                      'email', const Icon(Icons.person), emailController),
                  const SizedBox(height: 15),
                  textFieldBarPass('password', const Icon(Icons.lock),
                      passwordController, true),
                  const SizedBox(height: 5),
                  forgotPassword(screenWidth, context, "Forgot Password?",
                      CreateAccount.routeName, 16, () {
                    showForgotPasswordDialog(context);
                  }),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      loginButton(
                        screenWidth,
                        'Login',
                        24,
                        () => loginAction(context),
                      ),
                      const SizedBox(width: 20),
                      signUpBottom(screenWidth, context, "Sign-up",
                          CreateAccount.routeName, 24),
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

Future<void> loginAction(BuildContext context) async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  try {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      Navigator.pushReplacementNamed(context, DashBoard.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (error) {
    print("Supabase Error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login failed: ${error.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
