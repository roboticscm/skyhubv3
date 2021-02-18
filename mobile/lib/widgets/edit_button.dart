import 'package:flutter/material.dart';
import 'package:skyone_mobile/util/locale_resource.dart';

class EditButton extends StatelessWidget {
  final Function() onTap;
  final bool showText;

  const EditButton({this.onTap, this.showText = true});

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
            const Icon(Icons.edit),
            if(showText)
              const SizedBox(
                height: 5,
              ),
            if(showText)
              Text(
                LR.l10n('SYS.BUTTON.EDIT'),
              )
          ],
        ),
      ),
    );
  }
}
