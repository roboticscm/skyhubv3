import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/extension/string.dart';

class Dropdown extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final String title;
  final String errorText;
  final RxString rxStringId;
  final RxNum rxNumId;
  final List<Map<dynamic, dynamic>> data;
  final bool isRequire;
  final Function onValueChanged;
  final Function onIdChanged;

  bool hasSelected = false;

  Dropdown(
      {this.errorText,
      this.isRequire,
      this.title,
      this.rxStringId,
      this.rxNumId,
      this.data,
      this.onValueChanged,
      this.onIdChanged});

  @override
  Widget build(BuildContext context) {
    final selectValue = data?.firstWhere((e) => e['id'] == null)['value'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) Text(title),
        if (data != null && data.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => DropdownButton(
                onChanged: (newValue) {
                  hasSelected = true;
                  if (rxStringId != null) {
                    rxStringId.value = _getId(newValue as String) as String;
                  } else if (rxNumId != null) {
                    rxNumId.value = _getId(newValue as String) as num;
                  }
                  if (onValueChanged != null) {
                    onValueChanged(newValue);
                  }

                  if (onIdChanged != null) {
                    onIdChanged(_getId(newValue as String));
                  }
                },
                value: _getValue(rxStringId?.value ?? rxNumId?.value as String) ?? selectValue,
                items: data.map((e) {
                  final selectedId = rxStringId?.value ?? rxNumId?.value;
                  return DropdownMenuItem(
                    value: e['value'],
                    child: Text('${e['value']}',
                        style: TextStyle(
                            color: selectedId == e['id']
                                ? _themeController.getTextSelectionColor()
                                : _themeController.getThemeBodyTextColor())),
                  );
                }).toList(),
              ),
            ),
          ),
        if (isRequire ?? false)
          Obx(() {
            if (rxStringId?.value != null || rxNumId?.value != null) {
              return Container();
            } else {
              if(hasSelected) {
                return Text(
                  errorText ?? 'COMMON.MSG.ERROR'.t(),
                  style: TextStyle(color: _themeController.getErrorTextColor()),
                );
              } else {
                return Container();
              }
            }
          }),
      ],
    );
  }

  dynamic _getId(String value) {
    return data.firstWhere((e) => e['value'] == value)['id'];
  }

  String _getValue(String id) {
    return data.firstWhere((e) => e['id'] == id)['value'] as String;
  }
}
