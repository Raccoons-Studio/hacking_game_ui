import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/virtual_machine/common/evidence_switch.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:macos_ui/macos_ui.dart';

class FinderChat extends StatefulWidget {
  final Map<String, List<ConversationData>> conversations;

  const FinderChat({super.key, required this.conversations});

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
                        ? GenericConversation(conversation: _currentConversation!, scrollController: ScrollController(),)
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
        leading: CircleAvatar(
          radius: 30.0,
          backgroundImage: AssetImage('assets/images/avatar.jpeg'),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          conversations.keys.toList()[i],
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
        subtitle: Text(
            getLatestMessageDate(
                conversations.values.toList()[i]), // replace with actual date
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
    super.key,
    required this.conversation,
    required this.scrollController,
  });

  final List<ConversationData> conversation;

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
                margin: EdgeInsets.all(10),
                child: Text(
                  'Week: ${conversation[index].week}, Day: ${conversation[index].day}, Hour: ${conversation[index].hour}',
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
                return ConversationBubble(
                  data: conversation[index].conversation[i],
                  isUser: conversation[index].conversation[i].name == 'User',
                );
              },
            ),
            EvidenceSwitch(conversation[index].evidenceID,
                conversation[index].isMarkedAsEvidence),
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
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Text(
              data.content,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}
