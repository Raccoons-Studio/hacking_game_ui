import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';

StoryEngine getSampleStory() {
  List<CharacterEngine> characters = [];
  List<PlaceEngine> places = [];
  List<ElementEngine> elements = [];
  List<CaseEngine> cases = [];
  List<CinematicEngine> cinematics = [];

  places.add(
      PlaceEngine("REPAIR_SHOP", "Phone's repair", "avatar.jpeg", "The store where I work"));
  characters.add(CharacterEngine("ANNA", "Anna", 0, "anna.jpeg", "avatar.jpeg"));

  // Cinematiques
  cinematics.add(CinematicEngine("INTRO", "Introduction", 0, 1, 7, [
    CinematicSequenceEngine("INTRO-1", "week0_day1_cinematic_intro.jpg", [
      CinematicConversationEngine("Me", "Another day in this dingy phone repair shop. I swear the walls are closing in."),
      CinematicConversationEngine("Me", "Fixing cracked screens and water damaged phones for unappreciative customers really takes its toll."),
      CinematicConversationEngine("Me", "I'm just tired of the same old routine, day in and day out."),
      CinematicConversationEngine("Me", "This job is seriously testing the limits of my patience."),
      CinematicConversationEngine("Me", "Who knew that selling and repairing phones could be so... mind-numbingly boring?"),
      CinematicConversationEngine("Me", "There's got to be more to life than being trapped in this shop..."),
    ]),
    CinematicSequenceEngine("INTRO-2", "week0_day1_cinematic_intro1.jpg", [
      CinematicConversationEngine("Pretty girl", "Hi, I...umm...dropped my phone in the pool."),
      CinematicConversationEngine("Me", "Ugh, another water damage case."),
      CinematicConversationEngine("Pretty girl", "I'm really sorry, I know it's probably a pain to fix. But... it's weird, the screen still displays, I just can't interact with it."),
      CinematicConversationEngine("Me", "Hmm, interesting. Well, let's take a look and see what we can do."),
    ]),
    CinematicSequenceEngine("INTRO-3", "week0_day1_cinematic_intro2.jpg", [
      CinematicConversationEngine("Player", "Looks like the touch sensor is damaged, we'll need to replace the whole screen."),
      CinematicConversationEngine("Pretty girl", "Oh no... That sounds expensive. I'm just a student, I don't have a lot of money..."),
      CinematicConversationEngine("Player", "I understand. Let's see what we can do to make it affordable for you."),
    ]),
    CinematicSequenceEngine("INTRO-4", "week0_day1_cinematic_intro3.jpg", [
      CinematicConversationEngine("Player", "Well, I think I have a used screen that's still in good shape. I can put that in to keep the cost down. It should be ready in two hours."),
      CinematicConversationEngine("Anna", "That would be amazing, thank you so much! Oh, I'm Anna by the way."),
      CinematicConversationEngine("Player", "Nice to meet you, Anna. I'll do my best to get this fixed for you."),
    ]),
    CinematicSequenceEngine("INTRO-5", "week0_day1_cinematic_intro4.jpg", [
      CinematicConversationEngine("Player", "This damage is worse than I thought. It's going to take some effort to fix this."),
      CinematicConversationEngine("Player", "The water has really made its way into the internals, but fortunately, the motherboard seems untouched."),
      CinematicConversationEngine("Player", "As I'm studying the circuits and wires, my mind slips towards Anna. She's strikingly beautiful."),
      CinematicConversationEngine("Player", "A risky thought crosses my mind. That Beta spyware I found last month..."),
      CinematicConversationEngine("Player", "It's not the most ethical thing to do, but it does give me a chance to know more about her."),
      CinematicConversationEngine("Player", "The spyware is basic, it only gives access to phone logs and messages. But in my current state of boredom and curiosity, it's awfully tempting."),
    ]),
    CinematicSequenceEngine("INTRO-6", "week0_day1_cinematic_intro5.jpg", [
      CinematicConversationEngine("Player", "Alright, the repair is done. Now, for the spyware..."),
      CinematicConversationEngine("Player", "Just a quick install...and it's done. The icon is hidden, she'll never suspect a thing."),
      CinematicConversationEngine("Player", "Now, let's just test this real quick. I need to confirm it's sending data correctly before she takes the phone."),
    ]),
  ]));

  // Tutorial content
  elements.add(ElementEngine(
      "WEEK-0_DAY-1_HOUR-7_POSITION",
      placeID: "REPAIR_SHOP",
      "Phone's repair",
      "Anna's phone is in my hand, I think this damn spyware works.",
      "ANNA",
      EvidenceType.position,
      false,
      0,
      1,
      7));
  elements.add(ElementEngine(
      "WEEK-0_DAY-1_HOUR-7_HEARTBEAT",
      numberValue: 0,
      "Phone's repair",
      "I think her watch is too far from the phone",
      "ANNA",
      EvidenceType.heartbeat,
      false,
      0,
      1,
      7));
  elements.add(ElementEngine(
      "WEEK-0_DAY-1_HOUR-7_REARCAMERA",
      assetID: "week0_anna_day0_rear_camera_7.jpg",
      "Phone's repair",
      "Oh my god, it works ! I can see my desk !",
      "ANNA",
      EvidenceType.rearCamera,
      false,
      0,
      1,
      7));

  cinematics
      .add(CinematicEngine("TUTORIAL", "The tutorial is finish", 0, 1, 10, [
    CinematicSequenceEngine("TUTORIAL-1", "intro-1.jpg", [
      CinematicConversationEngine("Player",
          "Perfect, it's all working as planned. The functionalities are indeed limited for now, but they're good enough for a little sneak peek into her life."),
      CinematicConversationEngine("Player",
          "Knowing those sneaky developers, they'll surely roll out some new features in the coming weeks. I'll simply have to be patient."),
    ]),
    CinematicSequenceEngine("TUTORIAL-2", "intro-1.jpg", [
      CinematicConversationEngine(
          "Anna", "Hi again, I'm back! Is my phone ready?"),
    ]),
    CinematicSequenceEngine("TUTORIAL-2", "intro-1.jpg", [
      CinematicConversationEngine("Player",
          "Hi Anna, yes, your phone is all set. I managed to use a used screen for the repair, so there's no charge."),
      CinematicConversationEngine("Anna",
          "Oh my god, thank you so much! That's incredibly kind of you. I can't thank you enough!"),
    ]),
  ]));

  return StoryEngine(
      "sample_story",
      "Sample Story",
      "This is a sample story to test developments",
      characters,
      places,
      elements,
      cases,
      cinematics);
}

Player getSamplePlayer() {
  return Player("sample_player", 0, 1, 4, [], [], [], [], [], nsfwLevel: 0);
}
