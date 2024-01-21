import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/load_savegame.dart';
import 'package:hacking_game_ui/login_or_register.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/end/end.dart';
import 'package:hacking_game_ui/virtual_machine/virtual_desktop.dart';

class GameMenu extends StatefulWidget {
  Maestro? maestro;

  GameMenu({this.maestro});

  @override
  _GameMenuState createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu> {
  List<String> languages = ["English", "French", "Español"];
  String selectedLang = "English";
  bool isUserConnected = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<String> _validCodes = [];

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
                  'images/logo.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            buildNewGame(context),
            buildLoadGame(context),
            widget.maestro != null ? buildSaveGame(context) : Container(),
            isUserConnected ? SizedBox.shrink() : buildLoginOrRegister(context),
            isUserConnected ? buildMyAccount(context) : SizedBox.shrink(),
            isUserConnected ? buildLogout(context) : SizedBox.shrink(),
            widget.maestro != null
                ? buildManageCodes(context)
                : SizedBox.shrink(),
            buildLanguageSelection(context),
          ],
        ),
      ),
    );
  }

  TextButton buildLoadGame(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoadSaveGame()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_download_rounded,
            color: Colors.white,
          ),
          Text(FlutterI18n.translate(context, "load_game"),
              style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  TextButton buildNewGame(BuildContext context) {
    return TextButton(
      onPressed: () async {
        var maestro = Maestro();
        await maestro.start();
        _showCodePopup(maestro, _validCodes, () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MacOSDesktop(
                      maestro: maestro,
                    )),
          );
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gamepad_rounded,
            color: Colors.white,
          ),
          Text(FlutterI18n.translate(context, "new_game"),
              style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  TextButton buildSaveGame(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          bool isCloud = await widget.maestro!.save(0);
          // Si la sauvegarde est dans le cloud, on affiche une popup qui indique que le jeu a été sauvegardé dans le cloud.
          // Si la sauvegarde n'est pas dans le cloud, on affiche une popup qui indique que le jeu a été sauvegardé localement.
          if (isCloud) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(FlutterI18n.translate(context, "game_saved")),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                            FlutterI18n.translate(context, "game_saved_cloud")),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(FlutterI18n.translate(context, "game_saved")),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(FlutterI18n.translate(
                            context, "game_saved_locally")),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        } catch (error) {
          print(error);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_upload_rounded,
            color: Colors.white,
          ),
          Text(FlutterI18n.translate(context, "save_game"),
              style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  TextButton buildLoginOrRegister(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginOrRegister()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.app_registration,
            color: Colors.white,
          ),
          Text(FlutterI18n.translate(context, "register_or_login"),
              style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  TextButton buildMyAccount(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_rounded,
            color: Colors.white,
          ),
          Text(FlutterI18n.translate(context, "my_account"),
              style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  TextButton buildLogout(BuildContext context) {
    return TextButton(
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
          Text(FlutterI18n.translate(context, "logout"),
              style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  DropdownButton<String> buildLanguageSelection(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLang,
      icon: Icon(
        Icons.arrow_downward,
        color: Colors.white,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.white),
      dropdownColor: Colors.black,
      underline: Container(
        height: 2,
        color: Colors.white,
      ),
      onChanged: (String? newValue) async {
        await FlutterI18n.refresh(context,
            Locale.fromSubtags(languageCode: newValue!.substring(0, 2)));
        setState(() {
          selectedLang = newValue;
        });
      },
      items: languages.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          // value: value,
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  void _showCodePopup(
      Maestro maestro, List<String> validCodes, Function onPlay) {
    TextEditingController _codeController = TextEditingController();
    String _codeError = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Entrez votre code'),
            scrollable: true,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Les codes vous permettent de débloquer des éléments spécifiques du jeu. Rendez-vous sur Patreon pour en obtenir un !'),
                PatreonLink(maestro: maestro),
                Column(
                  children: validCodes
                      .map((code) => Row(
                            children: <Widget>[
                              Text(
                                code,
                                style: TextStyle(color: Colors.green),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() async {
                                    await maestro.removeCode(code);
                                    validCodes.remove(code);
                                  });
                                },
                              )
                            ],
                          ))
                      .toList(),
                ),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    errorText: _codeError.isNotEmpty ? _codeError : null,
                    labelText: 'Code',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Valider'),
                onPressed: () async {
                  String enteredCode = _codeController.text.trim();
                  if (await maestro.addCode(enteredCode)) {
                    setState(() {
                      validCodes.add(enteredCode);
                      _codeError =
                          ''; // Reset the error message if the code is valid
                    });
                  } else {
                    setState(() {
                      _codeError = 'Code invalide';
                    });
                  }
                },
              ),
              TextButton(child: Text('Jouer'), onPressed: () => onPlay()),
            ],
          );
        });
      },
    );
  }

  buildManageCodes(BuildContext context) {
    return TextButton(
      onPressed: () async {
        var codes = await widget.maestro!.getPlayerCodes();
        _showCodePopup(widget.maestro!, codes, () {
          Navigator.pop(context);
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code,
            color: Colors.white,
          ),
          Text('Manage codes', style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }
}
