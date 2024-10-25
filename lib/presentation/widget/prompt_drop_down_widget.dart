import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PromptDropdownWidget extends StatefulWidget {
  PromptDropdownWidget({super.key, required this.aiModels, required this.onChange});
  List<Map<String, String>> aiModels;
  ValueChanged<String?> onChange;

  @override
  _PromptDropdownWidgetState createState() => _PromptDropdownWidgetState();
}

class _PromptDropdownWidgetState extends State<PromptDropdownWidget> {
  late List<Map<String, String>> _promptModel;
  late String? _selectedModel;

  @override
  void initState() {
    super.initState();
    _promptModel = widget.aiModels;
    _selectedModel = widget.aiModels.last['name'];
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: Icon(FontAwesomeIcons.wandMagicSparkles),
      itemBuilder: (context) {
        return _promptModel.map((prompt) {
          return PopupMenuItem(
            value: prompt['name'],
            child: Row(
              children: [
                Text(prompt['name']??""),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (value) {
        setState(() {
          _selectedModel = value;
        });
        widget.onChange( _promptModel.firstWhere((model) => model['name'] == _selectedModel)['prompt']);
        // Handle selection here (e.g., navigate or update UI)
      },
    );

  }
}