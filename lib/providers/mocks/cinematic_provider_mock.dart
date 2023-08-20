import 'dart:math';

import 'package:hacking_game_ui/providers/cinematic_providers.dart';
import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';

class CinematicProviderMock extends CinematicProvider {
  @override
  Future<Cinematic> getCinematicData(String cinematicID) async {
    var random = Random();
  int numSequences = random.nextInt(5) + 5;
  int numConversations = random.nextInt(3) + 5;
  
  String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  
  String getCinematicID() => String.fromCharCodes(Iterable.generate(10, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  
  List<CinematicSequence> sequences = List.generate(numSequences, (indexSeq) {
    String assetName = 'assets/images/landscape.jpeg';
    List<CinematicConversation> conversations = List.generate(numConversations, (indexConv) {
        return CinematicConversation(
            'Character $indexSeq-$indexConv',
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi. Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, non fermentum diam nisl sit amet erat. Duis semper. Duis arcu massa, scelerisque vitae, consequat in, pretium a, enim.'
        );
    });
    return CinematicSequence(
        getCinematicID(),
        assetName,
        conversations
    );
  });
  
  return Cinematic(getCinematicID(), sequences);
  }
}