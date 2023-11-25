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

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _conversations = widget.maestro.getConversations().then((conversationMap) {
      if (conversationMap.isNotEmpty) {
        _selectedConversationKey = conversationMap.entries.first.key;
        _selectedConversation = conversationMap.entries.first.value;
      }
      // Auto-scroll to the end of the initial conversation.
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      return conversationMap;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.extraLightBackgroundGray,
      child: FutureBuilder<Map<String, List<ConversationData>>>(
        future: _conversations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const CircularProgressIndicator();
          else if (snapshot.connectionState == ConnectionState.done)
            return layoutBuilder(snapshot);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  LayoutBuilder layoutBuilder(
      AsyncSnapshot<Map<String, List<ConversationData>>> snapshot) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600)
          return rowDirector(snapshot);
        else
          return columnDirector(snapshot);
      },
    );
  }

  Row rowDirector(AsyncSnapshot<Map<String, List<ConversationData>>> snapshot) {
    return Row(
      children: [
        SizedBox(width: 300, child: listBuilder(snapshot)),
        buildConversation(),
      ],
    );
  }

  Widget columnDirector(
      AsyncSnapshot<Map<String, List<ConversationData>>> snapshot) {
    return _selectedConversation == null
        ? buildMobileContactList(snapshot)
        : Column(
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _selectedConversation = null),
                child: const Text('Back to conversations'),
              ),
              buildConversation(),
            ],
          );
  }

  ListView listBuilder(
      AsyncSnapshot<Map<String, List<ConversationData>>> snapshot) {
    return ListView.separated(
      itemCount: snapshot.data!.entries.length,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: buildListItem(snapshot),
    );
  }

  Widget? Function(BuildContext, int) buildListItem(
      AsyncSnapshot<Map<String, List<ConversationData>>> snapshot) {
    return (BuildContext context, int index) {
      var e = snapshot.data!.entries.toList()[index];
      return listItem(e);
    };
  }

  Container listItem(MapEntry<String, List<ConversationData>> e) {
    return Container(
      color: e.key == _selectedConversationKey
          ? CupertinoColors.lightBackgroundGray
          : Colors.transparent,
      child: ListTile(
        trailing: Icon(Icons.chevron_right),
        title: Text(e.key, style: listTitleStyle(e)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("${getDayOfWeek(e.value.last.day)} ${e.value.last.hour}:00"),
            /*Text(
              e.value.last.conversation.last.content,
              overflow: TextOverflow.ellipsis,
            ),*/
          ],
        ),
        isThreeLine: false,
        dense: false,
        onTap: () => setState(() {
          _selectedConversation = e.value;
          _selectedConversationKey = e.key;
        }),
      ),
    );
  }

  TextStyle listTitleStyle(MapEntry<String, List<ConversationData>> e) {
    return e.key == _selectedConversationKey
        ? const TextStyle(color: CupertinoColors.darkBackgroundGray)
        : e.value.last.isNow
            ? const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
            : const TextStyle(color: Colors.black);
  }

  ListView buildMobileContactList(
      AsyncSnapshot<Map<String, List<ConversationData>>> snapshot) {
    return listBuilder(snapshot);
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
                  scrollController: _scrollController,
                  showMarkAsEvidence: false,
                ),
              ),
              if (_selectedConversation!.last.conversation.last.name == 'Player' && 
                  !_selectedConversation!.last.conversation.last.isRevealed)
                responseContainer()
            ],
          ),
    );
  }

  Container responseContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          responseTextBox(),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => sendResponse(),
          ),
        ],
      ),
    );
  }

  Expanded responseTextBox() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(_selectedConversation!.last.conversation.last.content),
      ),
    );
  }

  Future<void> sendResponse() async {
    AnalyticsService().logPlayConversation(_selectedConversationKey!);
    await widget.maestro
        .collectConversation(_selectedConversation!.last.conversation.last.id);
    revealResponse();
    var newConversations = await widget.maestro.getConversations();
    if (newConversations[_selectedConversationKey] != null && newConversations[_selectedConversationKey]!.last.conversation.last.name != 'Player') {
      await Future.delayed(Duration(seconds: 3));
    }
    setState(() {
      _selectedConversation = newConversations[_selectedConversationKey];
    });
    _scrollToEnd();
  }

  void revealResponse() {
    setState(() {
      _selectedConversation!.last.conversation.last.isRevealed = true;
      _selectedConversation!.last.conversation.add(ConversationBubbleData(
          "ellispis", "", "...", ConversationBubbleDataEngineType.text));
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    });
    
  }
}
