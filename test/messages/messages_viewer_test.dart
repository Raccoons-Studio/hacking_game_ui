import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/virtual_machine/applications/messages/messages_viewer.dart';
import 'package:mockito/mockito.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:hacking_game_ui/virtual_machine/applications/finder/finder_chat.dart';

class MockMaestro extends Mock implements Maestro {}
class MockStoryEngine extends Mock implements StoryEngine {}

void main() {
  group('MessagesViewer widget', () {
    late Maestro mockMaestro;
    late StoryEngine mockStoryEngine;
    final isBlackMail = false;
    final caseID = '1';

    setUp(() {
      mockMaestro = MockMaestro();
      mockStoryEngine = MockStoryEngine();
    });

    testWidgets('should show CircularProgressIndicator when waiting for data', 
      (tester) async {
        when(mockMaestro.getConversations()).thenAnswer(
          (_) async => Future.delayed(Duration(seconds: 1)));

        await tester.pumpWidget(MaterialApp(
            home: MessagesViewer(
              maestro: mockMaestro,
              story: mockStoryEngine,
              isBlackMail: isBlackMail,
              caseID: caseID,
            ),
          ),
        );
        
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show Contact List after data fetched', 
      (tester) async {
        
        when(mockMaestro.getConversations()).thenAnswer(
          (_) async => Future.value({'key': [ConversationData('evidenceID', [
            ConversationBubbleData('id', 'name', 'content', ConversationBubbleDataEngineType.text)
          ], 1, 1, 1)]}));

        await tester.pumpWidget(MaterialApp(
            home: MessagesViewer(
              maestro: mockMaestro,
              story: mockStoryEngine,
              isBlackMail: isBlackMail,
              caseID: caseID,
            ),
          ),
        );

        await tester.pump(Duration(seconds: 1));

        expect(find.byType(ListView), findsOneWidget);
    });
  });
}