import 'package:flutter/material.dart';

GestureDetector monitorCard(
  int id,
  String custName,
  String address,
  String description,
  String price,
  String date,
  String volume,
  String quantity,
  screenWidth,
  screenHeight,
) {
  return GestureDetector(
    onTap: () {},
    child: Card(
      color: const Color(0xFFffca61),
      child: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(id.toString()),
                Text(custName),
                Text(address),
                Text(description),
                const Divider(),
                Text(volume),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFeab557),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "0/21,000",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(date),
                Text(volume),
                Text(quantity),
                Text(volume),
                const Divider(),
                Text(quantity),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFeab557),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "0/21",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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
