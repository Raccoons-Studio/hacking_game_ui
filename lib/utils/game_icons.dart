import 'package:flutter/cupertino.dart';
import 'package:hacking_game_ui/virtual_machine/models/directory_and_files.dart';

IconData getIconByType(FileType type) {
    switch (type) {
      case FileType.image:
        return CupertinoIcons.photo_fill_on_rectangle_fill;
      case FileType.text:
        return CupertinoIcons.pencil_ellipsis_rectangle;
      case FileType.calendar:
        return CupertinoIcons.calendar_circle_fill;
      case FileType.call:
        return CupertinoIcons.phone_circle_fill;
      case FileType.heartbeat:
        return CupertinoIcons.heart_circle_fill;
      case FileType.message:
        return CupertinoIcons.conversation_bubble;
      case FileType.note:
        return CupertinoIcons.text_bubble_fill;
      case FileType.position:
        return CupertinoIcons.map_fill;
      case FileType.socialMedia:
        return CupertinoIcons.camera_on_rectangle_fill;
      case FileType.webHistory:
        return CupertinoIcons.bookmark_fill;
      case FileType.directory:
        return CupertinoIcons.flag_circle;
      case FileType.bank:
        return CupertinoIcons.money_dollar_circle_fill;
      case FileType.deleted:
        return CupertinoIcons.trash_circle_fill;
      case FileType.frontCamera:
        return CupertinoIcons.camera_fill;
      case FileType.rearCamera:
        return CupertinoIcons.camera_rotate_fill;
      case FileType.microphone:
        return CupertinoIcons.mic_circle_fill;
    }
  }

  Color getColorByType(FileType type) {
    switch (type) {
      case FileType.image:
        return CupertinoColors.activeOrange;
      case FileType.text:
        return CupertinoColors.activeBlue;
      case FileType.calendar:
        return CupertinoColors.systemIndigo;
      case FileType.call:
        return CupertinoColors.systemGreen;
      case FileType.heartbeat:
        return CupertinoColors.systemPink;
      case FileType.message:
        return CupertinoColors.activeGreen;
      case FileType.note:
        return CupertinoColors.systemYellow;
      case FileType.position:
        return CupertinoColors.systemTeal;
      case FileType.socialMedia:
        return CupertinoColors.systemPurple;
      case FileType.webHistory:
        return CupertinoColors.systemGrey;
      case FileType.directory:
        return CupertinoColors.black;
      case FileType.bank:
        return CupertinoColors.systemBrown;
      case FileType.deleted:
        return CupertinoColors.lightBackgroundGray;
      case FileType.frontCamera:
        return CupertinoColors.activeOrange;
      case FileType.rearCamera:
        return CupertinoColors.activeOrange;
      case FileType.microphone:
        return CupertinoColors.systemRed;
    }
  }