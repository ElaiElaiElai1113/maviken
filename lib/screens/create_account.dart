import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:maviken/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maviken/screens/dashboard.dart';
import 'package:maviken/components/text_field_bar.dart';
import 'package:maviken/components/button_button.dart';

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final supabase = Supabase.instance.client;

class CreateAccount extends StatefulWidget {
  static const routeName = '/CreateAccount';

  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            return MobileCreateAccountView(
              emailController: _emailController,
              passwordController: _passwordController,
              supabase: supabase,
            );
          } else {
            return WebCreateAccountView(
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

class MobileCreateAccountView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final SupabaseClient supabase;

  const MobileCreateAccountView({
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
                      onPressed: () => createAccountAction(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
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

class WebCreateAccountView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final SupabaseClient supabase;

  const WebCreateAccountView({
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
                      'Email', const Icon(Icons.person), emailController),
                  const SizedBox(height: 15),
                  textFieldBarPass('Password', const Icon(Icons.lock),
                      passwordController, true),
                ],
              ),
              SizedBox(
                height: 50,
                width: screenWidth * .3,
                child: ElevatedButton(
                  onPressed: () => createAccountAction(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                width: screenWidth * .3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, LoginScreen.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: const Text(
                    'Already have an Account?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> createAccountAction(BuildContext context) async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Account created! Please check your email to verify your account.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create account'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account creation failed: ${error.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
