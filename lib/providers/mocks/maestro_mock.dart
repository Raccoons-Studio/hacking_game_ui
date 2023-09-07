import 'dart:math';

import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/phone/phone_characters_selector.dart';
import 'package:hacking_game_ui/virtual_machine/models/cinematic.dart';
import 'package:hacking_game_ui/virtual_machine/models/conversation_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';

class MaestroMock extends Maestro {
  MaestroState _state = MaestroState();
  MaestroState _saved = MaestroState();

  MaestroMock() {
    _state.hour = 7;
    _state.day = 0;
    _state.week = 0;
    _state.isCinematic = false;
    _state.cinematidID = '';
    super.streamController.add(_state);
  }

  @override
  Future<void> addToEvidence(String characterID, String evidenceID) {
    // TODO: implement addToEvidence
    throw UnimplementedError();
  }

  @override
  Future<void> load(String saveID) async {
    _state = _saved;
    super.streamController.add(_state);
  }

  @override
  Future<bool> nextHour(bool devMode) async {
    // TODO : Check if every evidences are collected
    // TODO : Check at the end of the day if every evidences are marked
    // TODO : Check at the end of the week if every evidences are submitted
    if (_state.hour >= 22) {
      _state.hour = 7;
      _state.day++;
      if (_state.day == 7) {
        _state.day = 0;
        _state.week++;
      }
    } else {
      _state.hour += 3;
    }
    super.streamController.add(_state);
    return true;
  }

  @override
  Future<void> removeFromEvidence(String characterID, String evidenceID) {
    // TODO: implement removeFromEvidence
    throw UnimplementedError();
  }

  @override
  Future<void> save() async {
    _saved = _state;
  }

  @override
  Future<void> submitEvidences(String characterID) async {
    super.streamController.add(_state);
  }

  @override
  Future<void> start() async {
    super.streamController.add(_state);
  }

  @override
  Future<void> collectEvidence(String evidenceID) {
    // TODO: implement collectEvidence
    throw UnimplementedError();
  }

  @override
  Future<List<Files>> getPhoneEvidences(String characterID) async {
    List<Files> files = [
      Files('File 1', 'Map', EvidenceType.position),
      Files('File_2', 'Gallery', EvidenceType.image),
      Files('File_2', 'Front camera', EvidenceType.frontCamera),
      Files('File_2', 'Rear camera', EvidenceType.rearCamera),
      Files('File_2', 'Deleted files', EvidenceType.deleted),
      Files('File 3', 'Calendar', EvidenceType.calendar),
      Files('File 4', 'Phone', EvidenceType.call, isMarkedAsEvidence: true),
      Files('File 4', 'Microphone', EvidenceType.microphone),
      Files('File 5', 'Health', EvidenceType.heartbeat),
      Files('File 6', 'Message', EvidenceType.message),
      Files('File 7', 'Note', EvidenceType.note),
      Files('File 7', 'Bank', EvidenceType.bank),
      Files('File 8', 'SocialMedia', EvidenceType.socialMedia),
      Files('File 9', 'Text', EvidenceType.text),
      Files('File 10', 'Browser', EvidenceType.webHistory),
    ];
    return files;
  }

  @override
  Future<Directory> getDirectory(String path) async {
    Directory currentDirectory = Directory("Root", "Root", [], []);
    currentDirectory.subdirectories.addAll([
      Directory(
          'SubDir 1',
          'SubDir 1',
          [],
          [
            Files('File 20', 'File 20', EvidenceType.image,
                parent: currentDirectory),
            Files('File 21', 'File 21', EvidenceType.image,
                parent: currentDirectory),
          ],
          parent: currentDirectory),
      Directory('SubDir 2', 'SubDir 2', [], [], parent: currentDirectory),
    ]);
    currentDirectory.files.addAll([
      Files('File 1', 'File 1', EvidenceType.position,
          parent: currentDirectory),
      Files('File_2', 'File 2', EvidenceType.image, parent: currentDirectory),
      Files('File 3', 'File 3', EvidenceType.calendar,
          parent: currentDirectory),
      Files('File 4', 'File 4', EvidenceType.call,
          parent: currentDirectory, isMarkedAsEvidence: true),
      Files('File 5', 'File 5', EvidenceType.heartbeat,
          parent: currentDirectory),
      Files('File 6', 'File 6', EvidenceType.message, parent: currentDirectory),
      Files('File 7', 'File 7', EvidenceType.note, parent: currentDirectory),
      Files('File 8', 'File 8', EvidenceType.socialMedia,
          parent: currentDirectory),
      Files('File 9', 'File 9', EvidenceType.text, parent: currentDirectory),
      Files('File 10', 'File 10', EvidenceType.webHistory,
          parent: currentDirectory),
      Files('File 11', 'File 11', EvidenceType.image, parent: currentDirectory),
      Files('File 12', 'File 12', EvidenceType.image, parent: currentDirectory),
      Files('File 13', 'File 13', EvidenceType.image, parent: currentDirectory),
      Files('File 14', 'File 14', EvidenceType.image, parent: currentDirectory),
      Files('File 15', 'File 15', EvidenceType.image, parent: currentDirectory),
      Files('File 16', 'File 16', EvidenceType.image, parent: currentDirectory),
      Files('File 17', 'File 17', EvidenceType.image, parent: currentDirectory),
      Files('File 18', 'File 18', EvidenceType.image, parent: currentDirectory),
      Files('File 19', 'File 19', EvidenceType.image, parent: currentDirectory),
    ]);
    return currentDirectory;
  }

  @override
  Future<String> getTextContent(Files file) async {
    return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque pulvinar eros id laoreet pulvinar. Praesent porttitor, risus eu tincidunt maximus, enim sapien vehicula nisi, nec posuere ipsum sem nec elit. Aliquam at lacus sed enim maximus venenatis. Aliquam sit amet laoreet nibh. Sed felis eros, facilisis eu commodo et, elementum a diam. Donec dictum velit id lectus tempus, non pellentesque libero porta. Aliquam tristique efficitur ligula at condimentum. Duis non nisi porta, consequat neque sit amet, maximus tellus. Morbi faucibus risus luctus pretium semper. Phasellus tristique tortor nibh, at scelerisque lacus sollicitudin a.\n Etiam vitae quam sed nibh facilisis gravida sit amet vel lacus. Nulla facilisi. Praesent tincidunt, ex et vehicula imperdiet, augue mauris dignissim metus, vitae consequat sem quam non eros. Praesent lacinia ac lacus sit amet gravida. In orci massa, venenatis vitae ipsum id, placerat imperdiet nisl. Vestibulum et tempor turpis. Phasellus id libero velit. Nunc lacus nibh, finibus in tortor vel, interdum convallis nulla. Praesent neque leo, tempus vel tempus non, pulvinar vel dui. Duis sagittis, risus vitae volutpat bibendum, orci dolor scelerisque arcu, vel porta nisi purus vel dui.\nEtiam congue quam a diam gravida rhoncus. Maecenas quis nisl viverra, fringilla purus at, commodo mauris. Ut non commodo sapien. Maecenas venenatis est libero, sed porttitor velit sodales sit amet. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus porttitor porttitor metus sodales faucibus. Integer venenatis est vitae nulla dapibus, nec sodales ligula varius. In eu tempor erat. Morbi in ipsum et nunc vehicula aliquet sit amet a lacus. Maecenas vitae magna tincidunt, lobortis massa sed, pellentesque lorem. Morbi dignissim est quis odio pulvinar rutrum. Sed sed ornare velit, quis posuere ex. Donec dictum vehicula lacus, eu mattis ex pharetra eget.\nVivamus sit amet quam tristique, blandit nunc at, pellentesque nulla. Donec varius mauris sit amet magna semper tristique. Sed vitae ex viverra, scelerisque libero eu, tristique libero. Fusce eget bibendum nisl, in suscipit lacus. Quisque imperdiet tortor et nisl scelerisque blandit. Suspendisse sollicitudin est neque. Sed quis bibendum erat. Proin pretium mi ante, at fringilla urna commodo eu. Cras vel tincidunt turpis. Mauris quis condimentum sem, id dictum ligula. In nec maximus mauris. In efficitur magna sed eros ultricies rutrum. Fusce pulvinar velit ac auctor vehicula. Praesent et lacinia libero, a tempor ante.\nSed mattis sed massa in fringilla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Morbi placerat arcu ligula, a pellentesque risus molestie vel. Phasellus nec cursus elit. Mauris turpis tortor, molestie eget volutpat ut, vestibulum ut ipsum. Etiam rutrum porta tristique. Fusce tempus ligula ut dui varius, ut congue tortor posuere. Nam quis est sed felis malesuada pretium quis et mi. Nunc porta quam a lectus volutpat placerat. Sed varius ex ac maximus viverra. Aliquam ac accumsan nulla. Vivamus volutpat ullamcorper erat, sit amet viverra ante maximus vitae.";
  }

  @override
  Future<List<TimelineData>> getTimelineData(Files file) async {
    List<TimelineData> timelineDataList = [];
    if (file.type == EvidenceType.position) {
      for (int i = 1; i <= 10; i++) {
        TimelineData timeline = TimelineData(
            1,
            i,
            i * 2,
            TimelineType.position,
            'Dummy content $i',
            // Random value between 0 and 1024
            PositionData('Dummy content $i', 'Dummy content $i', "avatar.jpeg", Random().nextInt(1024).toDouble(),
                Random().nextInt(1024).toDouble()));
        timelineDataList.add(timeline);
      }
    }
    if (file.type == EvidenceType.heartbeat) {
      for (int i = 1; i <= 10; i++) {
        var bpm = (60 + Random().nextInt(90));
        TimelineData timeline = TimelineData(
            1,
            i,
            i * 2,
            TimelineType.heartbeat,
            // A random number between 60 and 150
            bpm.toString(),
            bpm);
        timelineDataList.add(timeline);
      }
    }

    return timelineDataList;
  }

  @override
  Future<List<ScrollableData>> getScrollableData(Files file) async {
    List<ScrollableData> timelineDataList = [];

    if (file.type == EvidenceType.socialMedia) {
      for (int i = 1; i <= 10; i++) {
        ScrollableData timeline = ScrollableData(
          1,
          i,
          i * 2,
          ScrollableType.socialMedia,
          'assets/images/File_2.jpg',
          'Eating some super food !',
        );
        timelineDataList.add(timeline);
      }
    }

    if (file.type == EvidenceType.calendar) {
      for (int i = 1; i <= 10; i++) {
        ScrollableData timeline = ScrollableData(
          1,
          i,
          i * 2,
          ScrollableType.calendar,
          'Appointment with Dr. Strange',
          'Dr. Strange Office',
        );
        timelineDataList.add(timeline);
      }
    }

    if (file.type == EvidenceType.note) {
      for (int i = 1; i <= 10; i++) {
        ScrollableData timeline = ScrollableData(
          1,
          i,
          i * 2,
          ScrollableType.note,
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur dignissim at lorem ac sollicitudin. Phasellus ut neque blandit, cursus lectus nec, interdum tellus. Praesent efficitur mauris sit amet dolor suscipit, et bibendum purus efficitur. Donec erat enim, tincidunt et felis a, rhoncus fringilla massa. Morbi id quam in ante tempor mollis. Etiam ut arcu ut ipsum pellentesque porta. Aliquam turpis diam, commodo vel felis vitae, eleifend hendrerit mauris. Suspendisse at velit a tortor eleifend pretium. Mauris tellus lectus, tempus eu lacus eget, iaculis fermentum risus. Nam in enim odio.',
          'Note title',
        );
        timelineDataList.add(timeline);
      }
    }

    return timelineDataList;
  }

  @override
  Future<Map<String, List<ConversationData>>> getConversations() async {
    final Random random = Random();
    final List<String> names = ['User', 'Partner'];
    final Map<String, List<ConversationData>> conversations = {};

    for (var i = 0; i < names.length; i++) {
      List<ConversationData> convoData = [];
      for (var j = 0; j < 5; j++) {
        // 5 is the number of conversations
        List<ConversationBubbleData> bubbleData = [];
        for (var k = 0; k < 10; k++) {
          // 10 is the number of messages in each conversation
          bubbleData.add(ConversationBubbleData(names[random.nextInt(2)],
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur dignissim at lorem ac sollicitudin. Phasellus ut neque blandit, cursus lectus nec, interdum tellus. $k'));
        }
        convoData.add(ConversationData(
            (random.nextInt(52) + 1).toString(),
            bubbleData,
            random.nextInt(52) + 1,
            random.nextInt(7) + 1,
            random.nextInt(24)));
      }
      conversations[names[i]] = convoData;
    }

    return conversations;
  }

  @override
  Future<String> getAssetContent(Files file) async {
    return "File_2.jpg";
  }

  @override
  Future<List<Character>> getAllCharacters() async {
    return [];
  }

  @override
  Future<List<Character>> getAvailableCharacters() async {
    Random random = Random();

    List<Character> characters = List.generate(
      3,
      (index) => Character(
        characterID: 'character-${random.nextInt(1000)}',
        name: 'Character ${random.nextInt(1000)}',
        avatar: 'avatar.jpeg',
        wallpaper: 'wallpaper.jpeg',
      ),
    );

    return characters;
  }

  @override
  Future<Cinematic> getCinematicData(String cinematicID) async {
    var random = Random();
    int numSequences = random.nextInt(5) + 5;
    int numConversations = random.nextInt(3) + 5;

    String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    String getCinematicID() => String.fromCharCodes(Iterable.generate(
        10, (_) => characters.codeUnitAt(random.nextInt(characters.length))));

    List<CinematicSequence> sequences = List.generate(numSequences, (indexSeq) {
      String assetName = 'assets/images/landscape.jpeg';
      List<CinematicConversation> conversations =
          List.generate(numConversations, (indexConv) {
        return CinematicConversation('Character $indexSeq-$indexConv',
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi. Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, non fermentum diam nisl sit amet erat. Duis semper. Duis arcu massa, scelerisque vitae, consequat in, pretium a, enim.');
      });
      return CinematicSequence(assetName, conversations);
    });

    return Cinematic(getCinematicID(), sequences);
  }

  @override
  Future<TimelineData> getSingleTimelineData(Files file) async {
    return TimelineData(
        1,
        1,
        1 * 2,
        TimelineType.position,
        'Dummy content',
        // Random value between 0 and 1024
        PositionData('Dummy content', 'Dummy content', "avatar.jpeg", Random().nextInt(1024).toDouble(),
            Random().nextInt(1024).toDouble()));
  }

  @override
  Future<int> getNumberContent(Files file) async {
    return 90;
  }
  
  @override
  Future<List<ContactEngine>> getContacts() {
    // TODO: implement getContacts
    throw UnimplementedError();
  }
  
  @override
  Future<List<IntegrityError>> checkIntegrity(StoryEngine story) {
    // TODO: implement checkIntegrity
    throw UnimplementedError();
  }
  
  @override
  Future<StoryEngine> getStory() {
    // TODO: implement getStory
    throw UnimplementedError();
  }
  
  @override
  Future<void> goTo(int week, int day, int hour) {
    // TODO: implement goTo
    throw UnimplementedError();
  }
}
