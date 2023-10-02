import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';

class StoryEditorElementsWidget extends StatefulWidget {
  final List<ElementEngine> filteredElements;
  final StoryEngine story;
  StoryEditorElementsWidget(this.story, this.filteredElements, {super.key});

  @override
  State<StoryEditorElementsWidget> createState() => _StoryEditorElementsWidgetState();
}

class _StoryEditorElementsWidgetState extends State<StoryEditorElementsWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.filteredElements.length,
      itemBuilder: (context, index) {
        ElementEngine element = widget.filteredElements[index];
        List<int> hours = [7, 10, 13, 16, 19, 22];
        List<int> nsfwLevels = [0, 1, 2];
        return Row(
          children: [
            DropdownButton<int>(
              value: element.hour,
              items: hours.map((int hour) {
                return DropdownMenuItem<int>(
                  value: hour,
                  child: Text(hour.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    element.hour = newValue;
                    element.ID =
                        "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}-${element.nsfwLevel}";
                  }
                });
              },
            ),
            DropdownButton<EvidenceType>(
              value: element.type,
              onChanged: (EvidenceType? newValue) {
                setState(() {
                  if (newValue != null) {
                    element.type = newValue;
                    element.ID =
                        "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}-${element.nsfwLevel}";
                  }
                });
              },
              items: <EvidenceType>[
                EvidenceType.position,
                EvidenceType.rearCamera,
                EvidenceType.heartbeat,
                EvidenceType.socialMedia,
              ].map<DropdownMenuItem<EvidenceType>>((EvidenceType value) {
                return DropdownMenuItem<EvidenceType>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            ),
            Checkbox(
                value: element.isEvidence,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      element.isEvidence = value;
                      element.ID =
                          "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}-${element.nsfwLevel}";
                    });
                  }
                }),
            DropdownButton<String>(
              items: ['Case1', 'Case2', 'Case3'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
            DropdownButton<int>(
              value: element.nsfwLevel,
              items: nsfwLevels.map((int level) {
                return DropdownMenuItem<int>(
                  value: level,
                  child: Text(level.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    element.nsfwLevel = newValue;
                  }
                });
              },
            ),
            Expanded(
              child: SizedBox(
                width: 200,
                child: TextField(
                  controller: TextEditingController(text: element.description),
                  decoration: const InputDecoration(hintText: "Description"),
                  onChanged: (value) {
                    element.description = value;
                  },
                ),
              ),
            ),
            if (element.type == EvidenceType.position)
              SizedBox(
                width: 200,
                child: DropdownButton<PlaceEngine>(
                  value: element.placeID == null
                      ? null
                      : widget.story.places
                          .firstWhere((place) => place.ID == element.placeID),
                  items: widget.story.places.map((PlaceEngine place) {
                    return DropdownMenuItem<PlaceEngine>(
                      value: place,
                      child: Text(place.name),
                    );
                  }).toList(),
                  onChanged: (PlaceEngine? newValue) {
                    setState(() {
                      if (newValue != null) {
                        element.placeID = newValue.ID;
                      }
                    });
                  },
                ),
              ),
            if (element.type == EvidenceType.rearCamera)
              SizedBox(
                width: 200,
                child: TextField(
                  controller: TextEditingController(text: element.assetID),
                  decoration: const InputDecoration(hintText: "Asset ID"),
                  onChanged: (String newValue) {
                    element.assetID = newValue;
                  },
                ),
              ),
            if (element.type == EvidenceType.heartbeat)
              SizedBox(
                width: 200,
                child: TextField(
                  controller: TextEditingController(
                      text: element.numberValue.toString()),
                  decoration: const InputDecoration(hintText: "Heartbeat"),
                  onChanged: (String newValue) {
                    element.numberValue =
                        newValue.isEmpty ? 0 : int.parse(newValue);
                  },
                ),
              ),
            if (element.type == EvidenceType.socialMedia)
              SizedBox(
                width: 200,
                child: TextField(
                  controller: TextEditingController(text: element.assetID),
                  decoration: const InputDecoration(hintText: "Asset ID"),
                  onChanged: (String newValue) {
                    element.assetID = newValue;
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}