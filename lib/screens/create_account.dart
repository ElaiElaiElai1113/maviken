import 'package:flutter/material.dart';
import 'package:maviken/main.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final supabase = Supabase.instance.client;

Future<String> signUpEmailAndPassword(String email, String password) async {
  final response = await supabase.auth.signUp(email: email, password: password);
  final userID = response.user?.id;

  if (userID == null) {
    throw UnimplementedError();
  }
  return userID;
}

class createAccount extends StatefulWidget {
  static const routeName = '/createAccount';

  const createAccount({super.key});

  @override
  State<createAccount> createState() => _createAccountState();
}

class _createAccountState extends State<createAccount> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    createData();
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
              color: Color(0xFFffca61),
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: Image(
                    image: AssetImage('lib/assets/mavikenlogo.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFeab557),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      prefixIcon: Icon(Icons.person),
                      prefixIconColor: Colors.white,
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFeab557),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      prefixIcon: Icon(Icons.lock),
                      prefixIconColor: Colors.white,
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final createEmail = _emailController.text;
                          final createPassword = _passwordController.text;
                          signUpEmailAndPassword(createEmail, createPassword);
                        },
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                            Color(0xFFeab557),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            'CREATE AN ACCOUNT?',
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
      ),
    );
  }
}
