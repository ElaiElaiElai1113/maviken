import 'package:flutter/material.dart';

class NewOrder extends StatelessWidget {
  static const routeName = '/NewOrder';
  const NewOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xffeab557),
        title: Row(
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
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  elevation: MaterialStatePropertyAll(2),
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromARGB(255, 19, 121, 255),
                  ),
                ),
                onPressed: () {},
                child: const Text('New Order',
                    style: TextStyle(color: Colors.white, letterSpacing: 2)),
              ),
            ),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  elevation: MaterialStatePropertyAll(2),
                  backgroundColor: MaterialStatePropertyAll(
                    Color(0xff0a438f),
                  ),
                ),
                onPressed: () {},
                child: const Text('Tracking',
                    style: TextStyle(color: Colors.white, letterSpacing: 2)),
              ),
            ),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  elevation: MaterialStatePropertyAll(2),
                  backgroundColor: MaterialStatePropertyAll(
                    Color(0xff0a438f),
                  ),
                ),
                onPressed: () {},
                child: const Text('Delivery Receipts',
                    style: TextStyle(color: Colors.white, letterSpacing: 2)),
              ),
            ),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  elevation: MaterialStatePropertyAll(2),
                  backgroundColor: MaterialStatePropertyAll(
                    Color(0xff0a438f),
                  ),
                ),
                onPressed: () {},
                child: const Text('Accounts Receivables',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, letterSpacing: 2)),
              ),
            ),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  elevation: MaterialStatePropertyAll(2),
                  backgroundColor: MaterialStatePropertyAll(
                    Color(0xff0a438f),
                  ),
                ),
                onPressed: () {},
                child: const Text('Expenses',
                    style: TextStyle(color: Colors.white, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
