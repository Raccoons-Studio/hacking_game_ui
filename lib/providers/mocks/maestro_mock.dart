import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/providers/cinematic_providers.dart';
import 'package:hacking_game_ui/providers/files_providers.dart';
import 'package:hacking_game_ui/providers/mocks/cinematic_provider_mock.dart';
import 'package:hacking_game_ui/providers/mocks/files_provider_mock.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';

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
  CinematicProvider getCinematicProvider() {
    return CinematicProviderMock();
  }

  @override
  FilesProvider getFilesProvider() {
    return FilesProviderMock();
  }

  @override
  Future<void> load(String saveID) async {
    _state = _saved;
    super.streamController.add(_state);
  }

  @override
  Future<bool> nextHour() async {
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
  Future<void> submitEvidences(String characterID) async{
    super.streamController.add(_state);
  }
  
  @override
  Future<void> start() async {
    super.streamController.add(_state);
  }

  @override
  Future<Files> collectEvidence(String characterID, String evidenceID) {
    // TODO: implement collectEvidence
    throw UnimplementedError();
  }

  @override
  Future<List<Files>> getPhoneEvidences(String characterID) async {
    List<Files> files = [
    Files('File 1', 'File 1', FileType.position),
      Files('File_2', 'File 2', FileType.image),
      Files('File 3', 'File 3', FileType.calendar),
      Files('File 4', 'File 4', FileType.call, isMarkedAsEvidence: true),
      Files('File 5', 'File 5', FileType.heartbeat),
      Files('File 6', 'File 6', FileType.message),
      Files('File 7', 'File 7', FileType.note),
      Files('File 8', 'File 8', FileType.socialMedia),
      Files('File 9', 'File 9', FileType.text),
      Files('File 10', 'File 10', FileType.webHistory),
    ];
    return files;
  }

}