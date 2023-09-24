import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_chat.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';

class MessagesViewer extends StatefulWidget {
  final Maestro maestro;
  final StoryEngine story;

  MessagesViewer({Key? key, required this.maestro, required this.story})
      : super(key: key);

  @override
  _MessagesViewerState createState() => _MessagesViewerState();
}

class _MessagesViewerState extends State<MessagesViewer> {
  Future<Map<String, List<ConversationData>>>? _conversations;
  List<ConversationData>? _selectedConversation;
  String? _selectedConversationKey;

  @override
  void initState() {
    super.initState();
    _conversations = widget.maestro.getConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.extraLightBackgroundGray,
      child: FutureBuilder<Map<String, List<ConversationData>>>(
          future: _conversations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Container(
                        width: 300,
                        child: ListView(
                          children: snapshot.data!.entries.map((e) {
                            return Container(
                              color: e.key == _selectedConversationKey
                                        ? CupertinoColors.lightBackgroundGray
                                        : Colors.transparent,
                              child: ListTile(
                                title: Text(e.key,
                                    style: e.key == _selectedConversationKey
                                        ? TextStyle(color: CupertinoColors.darkBackgroundGray)
                                        : TextStyle(color: Colors.black)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        "${e.value.last.day} ${e.value.last.hour}:00"),
                                    Text(
                                      e.value.last.conversation.last.content,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                dense: false,
                                onTap: () {
                                  setState(() {
                                    _selectedConversation = e.value;
                                    _selectedConversationKey = e.key;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: _selectedConversation == null
                            ? Center(child: Text('Select a conversation'))
                            : GenericConversation(
                                conversation: _selectedConversation!,
                                scrollController: ScrollController(),
                                showMarkAsEvidence: false,
                              ),
                      ),
                    ],
                  );
                } else {
                  return _selectedConversation == null
                      ? ListView(
                          children: snapshot.data!.entries.map((e) {
                            return ListTile(
                              title: Text(e.key),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      "${e.value.last.day} ${e.value.last.hour}:00"),
                                  Text(
                                    e.value.last.conversation.last.content,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              dense: false,
                              onTap: () {
                                setState(() {
                                  _selectedConversation = e.value;
                                });
                              },
                            );
                          }).toList(),
                        )
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedConversation = null;
                                });
                              },
                              child: Text('Back to conversations'),
                            ),
                            Expanded(
                              child: GenericConversation(
                                conversation: _selectedConversation!,
                                scrollController: ScrollController(),
                              ),
                            ),
                          ],
                        );
                }
              });
            }
            return SizedBox.shrink();
          }),
    );
  }
}
