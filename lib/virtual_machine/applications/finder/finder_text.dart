import 'package:flutter/material.dart';

class FinderText extends StatelessWidget {
  final String text;

  const FinderText(this.text, {super.key});

  @override
     Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Text(
            text,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}