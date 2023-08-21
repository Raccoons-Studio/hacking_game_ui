import 'package:flutter/cupertino.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';

IconData getIconByType(EvidenceType type) {
    switch (type) {
      case EvidenceType.image:
        return CupertinoIcons.photo_fill_on_rectangle_fill;
      case EvidenceType.text:
        return CupertinoIcons.pencil_ellipsis_rectangle;
      case EvidenceType.calendar:
        return CupertinoIcons.calendar_circle_fill;
      case EvidenceType.call:
        return CupertinoIcons.phone_circle_fill;
      case EvidenceType.heartbeat:
        return CupertinoIcons.heart_circle_fill;
      case EvidenceType.message:
        return CupertinoIcons.conversation_bubble;
      case EvidenceType.note:
        return CupertinoIcons.text_bubble_fill;
      case EvidenceType.position:
        return CupertinoIcons.map_fill;
      case EvidenceType.socialMedia:
        return CupertinoIcons.camera_on_rectangle_fill;
      case EvidenceType.webHistory:
        return CupertinoIcons.bookmark_fill;
      case EvidenceType.directory:
        return CupertinoIcons.flag_circle;
      case EvidenceType.bank:
        return CupertinoIcons.money_dollar_circle_fill;
      case EvidenceType.deleted:
        return CupertinoIcons.trash_circle_fill;
      case EvidenceType.frontCamera:
        return CupertinoIcons.camera_fill;
      case EvidenceType.rearCamera:
        return CupertinoIcons.camera_rotate_fill;
      case EvidenceType.microphone:
        return CupertinoIcons.mic_circle_fill;
    }
  }

  Color getColorByType(EvidenceType type) {
    switch (type) {
      case EvidenceType.image:
        return CupertinoColors.activeOrange;
      case EvidenceType.text:
        return CupertinoColors.activeBlue;
      case EvidenceType.calendar:
        return CupertinoColors.systemIndigo;
      case EvidenceType.call:
        return CupertinoColors.systemGreen;
      case EvidenceType.heartbeat:
        return CupertinoColors.systemPink;
      case EvidenceType.message:
        return CupertinoColors.activeGreen;
      case EvidenceType.note:
        return CupertinoColors.systemYellow;
      case EvidenceType.position:
        return CupertinoColors.systemTeal;
      case EvidenceType.socialMedia:
        return CupertinoColors.systemPurple;
      case EvidenceType.webHistory:
        return CupertinoColors.systemGrey;
      case EvidenceType.directory:
        return CupertinoColors.black;
      case EvidenceType.bank:
        return CupertinoColors.systemBrown;
      case EvidenceType.deleted:
        return CupertinoColors.lightBackgroundGray;
      case EvidenceType.frontCamera:
        return CupertinoColors.activeOrange;
      case EvidenceType.rearCamera:
        return CupertinoColors.activeOrange;
      case EvidenceType.microphone:
        return CupertinoColors.systemRed;
    }
  }