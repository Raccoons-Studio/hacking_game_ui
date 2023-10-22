import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/analytics.dart';
import 'package:hacking_game_ui/utils/game_date.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_chat.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';

class MessagesViewer extends StatefulWidget {
  final Maestro maestro;
  final StoryEngine story;
  final bool isBlackMail;
  final String caseID;

  const MessagesViewer(
      {Key? key,
      required this.maestro,
      required this.story,
      required this.isBlackMail,
      required this.caseID})
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
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      SizedBox(
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
                                        ? const TextStyle(
                                            color: CupertinoColors
                                                .darkBackgroundGray)
                                        : e.value.last.isNow
                                            ? const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)
                                            : const TextStyle(
                                                color: Colors.black)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        "${getDayOfWeek(e.value.last.day)} ${e.value.last.hour}:00"),
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
                      buildConversation(),
                    ],
                  );
                } else {
                  return _selectedConversation == null
                      ? buildMobileContactList(snapshot)
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedConversation = null;
                                });
                              },
                              child: const Text('Back to conversations'),
                            ),
                            buildConversation(),
                          ],
                        );
                }
              });
            }
            return const SizedBox.shrink();
          }),
    );
  }

  ListView buildMobileContactList(
      AsyncSnapshot<Map<String, List<ConversationData>>> snapshot) {
    return ListView(
      children: snapshot.data!.entries.map((e) {
        return ListTile(
          title: Text(e.key),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("${getDayOfWeek(e.value.last.day)} ${e.value.last.hour}:00"),
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
        );
      }).toList(),
    );
  }

  Expanded buildConversation() {
    return Expanded(
      child: _selectedConversation == null
          ? const Center(child: Text('Select a conversation'))
          : Column(
              children: [
                Expanded(
                  child: GenericConversation(
                    conversation: _selectedConversation!,
                    scrollController: ScrollController(),
                    showMarkAsEvidence: false,
                  ),
                ),
                if (_selectedConversation!.last.conversation.last.name ==
                        'Player' &&
                    !_selectedConversation!.last.conversation.last.isRevealed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Text(_selectedConversation!
                                .last.conversation.last.content),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            AnalyticsService()
                                .logPlayConversation(_selectedConversationKey!);
                            await widget.maestro.collectConversation(
                                _selectedConversation!
                                    .last.conversation.last.id);
                            setState(() {
                              _selectedConversation!
                                  .last.conversation.last.isRevealed = true;
                              _selectedConversation!.last.conversation.add(
                                  ConversationBubbleData("ellispis", "", "...",
                                      ConversationBubbleDataEngineType.text));
                            });
                            await Future.delayed(Duration(seconds: 3));
                            var newConversations =
                                await widget.maestro.getConversations();
                            setState(() {
                              _selectedConversation =
                                  newConversations[_selectedConversationKey];
                            });
                          },
                        )
                      ],
                    ),
                  )
              ],
            ),
    );
  }
}
