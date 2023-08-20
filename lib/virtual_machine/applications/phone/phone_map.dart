import 'package:flutter/material.dart';

class PhoneMap extends StatelessWidget {
  final String location;
  final String hour;
  final String day;

  const PhoneMap({
    Key? key,
    required this.location,
    required this.hour,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.pin_drop,
                size: 300.0,
                color: Colors.black,
              ),
            ),
          ),
          Center(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '$location',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                '$hour $day',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}