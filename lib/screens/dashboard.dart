import 'package:flutter/material.dart';

class DashBoard extends StatelessWidget {
  static const routeName = '/DashBoard';
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 200,
        backgroundColor: Color(0xffeab557),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 50),
            const Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                child: Image(
                  image: AssetImage('lib/assets/mavikenlogo.png'),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        elevation: MaterialStatePropertyAll(2),
                        backgroundColor: MaterialStatePropertyAll(
                          Color(0xff0a438f),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('New Order',
                          style:
                              TextStyle(color: Colors.white, letterSpacing: 2)),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        elevation: MaterialStatePropertyAll(2),
                        backgroundColor: MaterialStatePropertyAll(
                          Color(0xff0a438f),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Tracking',
                          style:
                              TextStyle(color: Colors.white, letterSpacing: 2)),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        elevation: MaterialStatePropertyAll(2),
                        backgroundColor: MaterialStatePropertyAll(
                          Color(0xff0a438f),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Delivery Receipts',
                          style:
                              TextStyle(color: Colors.white, letterSpacing: 2)),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        elevation: MaterialStatePropertyAll(2),
                        backgroundColor: MaterialStatePropertyAll(
                          Color(0xff0a438f),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Accounts Receivables',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white, letterSpacing: 2)),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                        elevation: MaterialStatePropertyAll(2),
                        backgroundColor: MaterialStatePropertyAll(
                          Color(0xff0a438f),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Expenses',
                          style:
                              TextStyle(color: Colors.white, letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
