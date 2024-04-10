import 'package:flutter/material.dart';
import 'package:maviken/main.dart';
import 'package:maviken/components/textFieldBar.dart';
import 'package:maviken/functions.dart';
import 'package:maviken/screens/loginScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController firstName = TextEditingController();
final TextEditingController lastName = TextEditingController();
final TextEditingController addressLine = TextEditingController();
final TextEditingController city = TextEditingController();
final TextEditingController barangay = TextEditingController();
final TextEditingController contactNum = TextEditingController();

final supabase = Supabase.instance.client;

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

    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        color: const Color(0xFFFCF7E6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
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
                  textFieldBar(
                      'Email', const Icon(Icons.person), emailController),
                  textFieldBarPass('Password', const Icon(Icons.lock),
                      passwordController, true),
                  textFieldBar(
                      'First Name', const Icon(Icons.person_2), firstName),
                  textFieldBar(
                      'Last Name', const Icon(Icons.person_3), lastName),
                  textFieldBar(
                      'Address Line', const Icon(Icons.book), addressLine),
                  textFieldBar('City', const Icon(Icons.build), city),
                  textFieldBar('Barangay', const Icon(Icons.house), barangay),
                  textFieldBar(
                      'Contact Number', const Icon(Icons.numbers), contactNum),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width * .2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final createEmail = emailController.text;
                            final createPassword = passwordController.text;
                            signUpEmailAndPassword(createEmail, createPassword);
                            createEmployee();

                            Navigator.popAndPushNamed(
                                context, LoginScreen.routeName);
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
                              textAlign: TextAlign.center,
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
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width * .2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.popAndPushNamed(
                            context, LoginScreen.routeName);
                      },
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Color(0xFFeab557),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'ALREADY HAVE AN ACCOUNT?',
                          textAlign: TextAlign.center,
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
            ),
          ),
        ),
      ),
    );
  }
}
