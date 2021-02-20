import 'package:flutter/material.dart';
import 'package:skyone_mobile/extension/string.dart';

class EditButton extends StatelessWidget {
  final Function() onPressed;
  final bool showText;

  const EditButton({this.onPressed, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit),
          if (showText) Text('SYS.BUTTON.EDIT'.t()) else Container()
        ],
      ),
    );
  }
}
