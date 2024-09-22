import 'package:flutter/material.dart';

Container signUpBottom(double screenWidth, BuildContext context,
    String texttitle, routeName, size) {
  return Container(
      width: screenWidth * .08,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Color(0xFFEAB557),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 4),
              blurRadius: 3.0,
            )
          ]),
      child: TextButton(
        onPressed: () async {
          Navigator.pushNamed(context, routeName);
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            texttitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: size,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ));
}

Container loginButton(double screenWidth, String texttitle, size, function) {
  return Container(
    width: screenWidth * .08,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          offset: Offset(0, 4),
          blurRadius: 3,
        )
      ],
    ),
    child: TextButton(
      onPressed: function,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          texttitle,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: const Color(0xFF192B89),
              fontSize: size,
              fontWeight: FontWeight.w900,
              decorationColor: Colors.white),
        ),
      ),
    ),
  );
}

SizedBox forgotPassword(double screenWidth, BuildContext context,
    String texttitle, routeName, size) {
  return SizedBox(
    width: screenWidth * .15,
    child: TextButton(
      onPressed: () async {
        Navigator.pushNamed(context, routeName);
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          texttitle,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: size,
              fontWeight: FontWeight.w900,
              decorationColor: Colors.white),
        ),
      ),
    ),
  );
}
