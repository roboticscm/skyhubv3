import 'package:flutter/material.dart';
import 'package:skyone_mobile/util/locale_resource.dart';

class SCloseButton extends StatelessWidget {
  final Function() onTap;
  final Color color;
  final bool showText;

  const SCloseButton({this.onTap, this.color, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(color: Colors.red, child: Icon(Icons.close, color: color)),
            if(showText)
              const SizedBox(
                height: 5,
              ),
            if(showText)
              Text(
                LR.l10n('COMMON.BUTTON.CLOSE'),
                style: TextStyle(color: color),
              )
          ],
        ),
      ),
    );
  }
}
