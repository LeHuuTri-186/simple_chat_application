import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CollapsibleRowTool extends StatefulWidget {
  CollapsibleRowTool({super.key, required this.widgets});
  List<Widget> widgets = <Widget>[];

  @override
  State<CollapsibleRowTool> createState() => _CollapsibleRowToolState();
}

class _CollapsibleRowToolState extends State<CollapsibleRowTool> {
  var _isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    if (_isCollapsed) {
      return Row(
            children: [
              IconButton(
                  onPressed: () => setState(() {
                        _isCollapsed = false;
                      }),
                  icon: Icon(Icons.add_outlined))
            ],
          );
    } else {
      widget.widgets.add(IconButton(
          onPressed: () => setState(() {
            _isCollapsed = true;
            widget.widgets.removeLast();
          }),
          icon: Icon(Icons.arrow_left))
      );

      return Row(children: widget.widgets);
    }
  }
}
