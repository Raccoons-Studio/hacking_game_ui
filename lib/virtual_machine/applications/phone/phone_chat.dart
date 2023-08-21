import 'package:flutter/material.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_chat.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';

class MobileFinderChat extends StatefulWidget {
  final Map<String, List<ConversationData>> conversations;

  const MobileFinderChat({Key? key, required this.conversations})
      : super(key: key);

  @override
  _MobileFinderChatState createState() => _MobileFinderChatState();
}

class _MobileFinderChatState extends State<MobileFinderChat> {
  List<ConversationData>? _currentConversation;
  bool showConversation = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.conversations.isNotEmpty) {
      _currentConversation = widget.conversations.entries.first.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: showConversation
            ? GenericConversation(
                conversation: _currentConversation!,
                scrollController: _scrollController,
              )
            : buildContacts(widget.conversations));
  }

  int selectedContactIndex = 0;

  Widget buildContacts(Map<String, List<ConversationData>> conversations) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            radius: 30.0,
            backgroundImage: AssetImage('assets/images/avatar.jpeg'),
          ),
          title: Text(conversations.keys.toList()[index]),
          selected: index == selectedContactIndex,
          subtitle:
              Text(getLatestMessageDate(conversations.values.toList()[index])),
          onTap: () {
            setState(() {
              _currentConversation = conversations.values.toList()[index];
              selectedContactIndex = index;
              showConversation = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              });
            });
          },
        );
      },
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
