import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hacking_game_ui/engine/save_load_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/maestro/maestro_story.dart';
import 'package:hacking_game_ui/providers/savegame_service.dart';

import 'virtual_machine/virtual_desktop.dart';

class LoadSaveGame extends StatefulWidget {
  LoadSaveGame();

  @override
  _LoadSaveGameState createState() => _LoadSaveGameState();
}

class _LoadSaveGameState extends State<LoadSaveGame> {
  List<Savegame> gameSaves = [];

  @override
  void initState() {
    super.initState();
    loadSaves();
  }

  loadSaves() async {
    gameSaves = await SavegameService().listSave();
    gameSaves.addAll(await SavegameService().getLocalSaveGame());
    gameSaves.sort((a, b) => b.week.compareTo(a.week));
    setState(() {});
  }

  Future<void> _confirmDeleteDialog(BuildContext context, String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(FlutterI18n.translate(context, "confirm_delete")),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(FlutterI18n.translate(context, "confirm_delete_message")),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(FlutterI18n.translate(context, "cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(FlutterI18n.translate(context, "delete")),
              onPressed: () {
                SavegameService().delete(id);
                loadSaves();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: gameSaves.isEmpty
            ? Text(
                FlutterI18n.translate(context, "no_save_yet"),
                style: TextStyle(color: Colors.white),
              )
            : SizedBox(
                width: 600,
                child: ListView.builder(
                  itemCount: gameSaves.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "Savegame ${index + 1}",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Week: ${gameSaves[index].week}, Day: ${gameSaves[index].day}, Hour: ${gameSaves[index].hour}',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onPressed: () => _confirmDeleteDialog(
                                context, gameSaves[index].id),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                var maestro = MaestroStory();
                                var save = gameSaves[index];
                                await maestro.load(save.player);
                                await maestro.nextHour(false, false);
                                // TODO : Vérifier les codes, supprimer les codes inactifs et redemander les codes au joueur
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MacOSDesktop(
                                            maestro: maestro,
                                          )),
                                );
                              }),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
