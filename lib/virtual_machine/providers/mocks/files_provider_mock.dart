import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';
import 'package:hacking_game_ui/virtual_machine/models/scrollable_data.dart';
import 'package:hacking_game_ui/virtual_machine/models/timeline_data.dart';
import 'package:hacking_game_ui/virtual_machine/providers/files_providers.dart';

class FilesProviderMock extends FilesProvider {
  @override
  Future<Directory> getDirectory(String path) async {
    Directory currentDirectory = Directory("Root", "Root", [], []);
    currentDirectory.subdirectories.addAll([
      Directory(
          'SubDir 1',
          'SubDir 1',
          [],
          [
            Files('File 20', 'File 20', FileType.image,
                parent: currentDirectory),
            Files('File 21', 'File 21', FileType.image,
                parent: currentDirectory),
          ],
          parent: currentDirectory),
      Directory('SubDir 2', 'SubDir 2', [], [], parent: currentDirectory),
    ]);
    currentDirectory.files.addAll([
      Files('File 1', 'File 1', FileType.timeline, parent: currentDirectory),
      Files('File_2', 'File 2', FileType.image, parent: currentDirectory),
      Files('File 3', 'File 3', FileType.scrollable, parent: currentDirectory),
      Files('File 4', 'File 4', FileType.image, parent: currentDirectory),
      Files('File 5', 'File 5', FileType.image, parent: currentDirectory),
      Files('File 6', 'File 6', FileType.image, parent: currentDirectory),
      Files('File 7', 'File 7', FileType.text, parent: currentDirectory),
      Files('File 8', 'File 8', FileType.text, parent: currentDirectory),
      Files('File 9', 'File 9', FileType.image, parent: currentDirectory),
      Files('File 10', 'File 10', FileType.image, parent: currentDirectory),
      Files('File 11', 'File 11', FileType.timeline, parent: currentDirectory),
      Files('File 12', 'File 12', FileType.image, parent: currentDirectory),
      Files('File 13', 'File 13', FileType.scrollable, parent: currentDirectory),
      Files('File 14', 'File 14', FileType.image, parent: currentDirectory),
      Files('File 15', 'File 15', FileType.scrollable, parent: currentDirectory),
      Files('File 16', 'File 16', FileType.image, parent: currentDirectory),
      Files('File 17', 'File 17', FileType.image, parent: currentDirectory),
      Files('File 18', 'File 18', FileType.image, parent: currentDirectory),
      Files('File 19', 'File 19', FileType.image, parent: currentDirectory),
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

    for (int i = 1; i <= 10; i++) {
      TimelineData timeline = TimelineData(
        1,
        i,
        i * 2,
        TimelineType.position,
        'Dummy content $i',
      );
      timelineDataList.add(timeline);
    }

    return timelineDataList;
  }

  @override
  Future<List<ScrollableData>> getScrollableData(Files file) async {
    List<ScrollableData> timelineDataList = [];

    for (int i = 1; i <= 10; i++) {
      ScrollableData timeline = ScrollableData(
        1,
        i,
        i * 2,
        ScrollableType.socialMedia,
        'Dummy content $i',
        'Dummy subcontent $i',
      );
      timelineDataList.add(timeline);
    }

    return timelineDataList;
  }
}
