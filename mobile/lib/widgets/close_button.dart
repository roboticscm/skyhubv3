import 'package:flutter/material.dart';
import 'package:skyone_mobile/extension/string.dart';

class SCloseButton extends StatelessWidget {
  final Function() onPressed;
  final bool showText;

  const SCloseButton({this.onPressed, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        if(onPressed != null) {
          onPressed();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.close),
          if (showText) Text('SYS.BUTTON.CLOSE'.t()) else Container()
        ],
      ),
    );
  }
}
