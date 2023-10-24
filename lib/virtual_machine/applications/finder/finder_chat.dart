import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/utils/game_date.dart';
import 'package:hacking_game_ui/virtual_machine/common/evidence_switch.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:macos_ui/macos_ui.dart';

class FinderChat extends StatefulWidget {
  final Map<String, List<ConversationData>> conversations;

  const FinderChat({Key? key, required this.conversations}) : super(key: key);

  @override
  State<FinderChat> createState() => _FinderChatState();
}

class _FinderChatState extends State<FinderChat> {
  List<ConversationData>? _currentConversation;

  @override
  void initState() {
    super.initState();
    if (widget.conversations.isNotEmpty) {
      _currentConversation = widget.conversations.entries.first.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      children: [
        ResizablePane(
          minSize: 180,
          startSize: 200,
          windowBreakpoint: 700,
          resizableSide: ResizableSide.right,
          builder: (_, __) {
            return buildContacts(widget.conversations);
          },
        ),
        ContentArea(
          builder: (_, __) {
            return Column(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    child: _currentConversation != null
                        ? GenericConversation(
                            conversation: _currentConversation!,
                            scrollController: ScrollController())
                        : Container(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  int favoritePageIndex = 0;

  Widget buildContacts(Map<String, List<ConversationData>> conversations) {
    List<Widget> items = [];
    for (var i = 0; i < conversations.length; i++) {
      bool isSelected = favoritePageIndex == i;
      items.add(ListTile(
        leading: const CircleAvatar(
          radius: 30.0,
          backgroundImage: AssetImage('assets/images/avatar.jpeg'),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          conversations.keys.toList()[i],
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
        subtitle: Text(getLatestMessageDate(conversations.values.toList()[i]),
            style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
        tileColor: Colors.transparent,
        selectedColor: CupertinoColors.activeBlue,
        selected: favoritePageIndex == i,
        focusColor: CupertinoColors.activeBlue,
        onTap: () {
          setState(() {
            _currentConversation = conversations.values.toList()[i];
            favoritePageIndex = i;
          });
        },
      ));
    }

    return ListView(
      children: items,
    );
  }

  String getLatestMessageDate(List<ConversationData> conversationData) {
    ConversationData latestMessage = conversationData.reduce((curr, next) =>
        DateTime(curr.week, curr.day, curr.hour)
                .isAfter(DateTime(next.week, next.day, next.hour))
            ? curr
            : next);
    return '${latestMessage.day} ${latestMessage.hour}h';
  }
}

class GenericConversation extends StatelessWidget {
  final ScrollController scrollController;

  const GenericConversation({
    Key? key,
    required this.conversation,
    required this.scrollController,
    this.showMarkAsEvidence = true,
  }) : super(key: key);

  final List<ConversationData> conversation;
  final bool showMarkAsEvidence;

  @override
  Widget build(BuildContext context) {
    conversation.sort((a, b) {
      if (a.week == b.week) {
        if (a.day == b.day) {
          return a.hour.compareTo(b.hour);
        } else {
          return a.day.compareTo(b.day);
        }
      } else {
        return a.week.compareTo(b.week);
      }
    });

    return ListView.builder(
      controller: scrollController,
      itemCount: conversation.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Text(
                  '${getDayOfWeek(conversation[index].day)} ${conversation[index].hour}:00',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: conversation[index].conversation.length,
              itemBuilder: (context, i) {
                final data = conversation[index].conversation[i];
                final isUser = data.name == 'Player';
                return ConversationBubble(
                  data: data,
                  isUser: isUser,
                );
              },
            ),
            showMarkAsEvidence
                ? EvidenceSwitch(conversation[index].evidenceID,
                    conversation[index].isMarkedAsEvidence)
                : Container(),
          ],
        );
      },
    );
  }
}

class ConversationBubble extends StatelessWidget {
  final ConversationBubbleData data;
  final bool isUser;

  const ConversationBubble({
    Key? key,
    required this.data,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (this.isUser && !this.data.isRevealed) {
      return Container();
    }
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 2 / 3),
            child: Container(
              decoration: BoxDecoration(
                color: isUser
                    ? CupertinoColors.activeGreen
                    : CupertinoColors.lightBackgroundGray,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: _getContentBasedOnType(context),
            ),
          );
        },
      ),
    );
  }

// This function creates different types of content based on data type
  Widget _getContentBasedOnType(BuildContext context) {
    if (data.type == ConversationBubbleDataEngineType.text) {
      return Text(
        data.content,
        style: TextStyle(
          fontSize: 14,
          color: isUser ? Colors.white : Colors.black,
        ),
      );
    }

    if (data.type == ConversationBubbleDataEngineType.bank) {
      return Column(
        children: [
          Text("Vous venez de recevoir un paiement"),
          Text(
            data.content,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text("Cette somme est désormais disponible sur votre compte"),
        ],
      );
    }

    if (data.type == ConversationBubbleDataEngineType.image) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Image.asset('assets/images/' + data.content),
              );
            },
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 100,
          ),
          child: Image.asset('assets/images/' + data.content),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
