import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';

mixin MaestroCodes {
  Code? _prefixCode;

  Future<bool> addCodeMixin(StoryEngine s, Player p, String codeStr) async {
    for (var code in s.codes) {
      var bytes = utf8.encode(codeStr); // data being hashed
      var digest = sha1.convert(bytes);
      if (code.name == digest.toString()) {
        p.codes.add(codeStr);
        if (code.type == CodeType.prefix) {
          _prefixCode = code;
        }
        return true;
      }
    }
    return false;
  }

  Future<void> removeCodeMixin(StoryEngine s, Player p, String codeStr) async {
    p.codes.remove(codeStr);
  }

  Future<List<Code>> getCodesMixin(
    StoryEngine s,
    Player p,
  ) async {
    List<Code> codes = [];
    for (var code in s.codes) {
      for (var codePlayer in p.codes) {
        if (code.name == codePlayer) {
          codes.add(code);
          if (code.type == CodeType.prefix) {
            _prefixCode = code;
          }
        }
      }
    }
    return codes;
  }

  Future<List<String>> getPlayerCodesMixin(Player p) async {
    return p.codes;
  }

  Code? getPrefixCode() {
    return _prefixCode;
  }

  Future<bool> checkCodeAvailabilityMixin(StoryEngine s, Player p) async {
    for (var codePlayer in p.codes) {
      bool isCodePlayerAvailable = false;
      for (var code in s.codes) {
        if (code.name == codePlayer) {
          isCodePlayerAvailable = true;
        }
      }
      if (!isCodePlayerAvailable) {
        return false;
      }
    }
    return true;
  }

  Future<String> getPatreonCodeMixin(StoryEngine s) async {
    return s.patreonLink;
  }
}
