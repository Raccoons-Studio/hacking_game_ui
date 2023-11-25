import 'package:flutter/material.dart';
import 'package:hacking_game_ui/providers/newsletter_service.dart';
import 'package:hacking_game_ui/virtual_machine/models/application.dart';
import 'dart:html' as html;

class TheEndWidget extends StatefulWidget implements VirtualApplication {
  Function _displaySettings;
  TheEndWidget(this._displaySettings, {super.key});

  @override
  State<TheEndWidget> createState() => _TheEndWidgetState();

  @override
  bool isNotification = false;

  @override
  Color get color => throw UnimplementedError();

  @override
  IconData get icon => throw UnimplementedError();

  @override
  String get name => "The_End";
}

class _TheEndWidgetState extends State<TheEndWidget> {
  String email = "";
  @override
  Widget build(BuildContext context) {
    return buildTheEnd();
  }

  Expanded buildTheEnd() {
    return Expanded(
        child: Container(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "This is the end... for now !",
            style: const TextStyle(color: Colors.white, fontSize: 50),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Inscrivez-vous à la newsletter pour être tenu au courant lorsqu'un nouvel épisode est disponible",
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Entrez votre email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              if (email.isNotEmpty) {
                try {
                  await NewsLetterProvider().save(email);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Inscription à la newsletter'),
                        content: Text('Inscription validée!'),
                      );
                    },
                  );
                } catch (e) {
                  print('Error: $e');
                }
              }
            }, // Implement the sign-up logic here
            child: Text('S\'inscrire'),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              widget._displaySettings();
            }, // Implement sign-in and save logic here
            child: Text(
              'Connectez-vous ou inscrivez-vous pour sauvegarder votre partie dans le cloud',
              style: const TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              html.window.open('https://patreon.com/RaccoonStudio', 'new tab');
            },
            child: Text(
              'Soutenez notre travail sur Patreon!',
              style: const TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ));
  }
}
