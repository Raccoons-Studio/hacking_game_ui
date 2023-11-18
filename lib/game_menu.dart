import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/load_savegame.dart';
import 'package:hacking_game_ui/login_or_register.dart';
import 'package:hacking_game_ui/maestro/maestro_story.dart';
import 'package:hacking_game_ui/virtual_machine/virtual_desktop.dart';

class GameMenu extends StatefulWidget {
  @override
  _GameMenuState createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu> {
  List<String> languages = ["English", "French", "Spanish", "German"];
  String selectedLang = "English";
  bool isUserConnected = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      setState(() {
        isUserConnected = true;
      });
    }
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          isUserConnected = false;
        });
      } else {
        setState(() {
          isUserConnected = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/penny_single_fans_logo.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MacOSDesktop(
                            maestro: MaestroStory(),
                          )),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gamepad_rounded,
                    color: Colors.white,
                  ),
                  Text(' New Game', style: TextStyle(color: Colors.white))
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (isUserConnected) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoadSaveGame()),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_download_rounded,
                    color: Colors.white,
                  ),
                  Text(' Load Game', style: TextStyle(color: Colors.white))
                ],
              ),
            ),
            isUserConnected
                ? SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginOrRegister()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.app_registration,
                          color: Colors.white,
                        ),
                        Text('Register/login',
                            style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
            isUserConnected
                ? TextButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_circle_rounded,
                          color: Colors.white,
                        ),
                        Text(' My Account',
                            style: TextStyle(color: Colors.white))
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            isUserConnected
                ? TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        Text(' Logout', style: TextStyle(color: Colors.white))
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            DropdownButton<String>(
              value: selectedLang,
              icon: Icon(
                Icons.arrow_downward,
                color: Colors.white,
              ),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.white),
              underline: Container(
                height: 2,
                color: Colors.white,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLang = newValue!;
                });
              },
              items: languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  // value: value,
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
