import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/global/const.dart';

class RxCheckbox extends StatelessWidget {
  RxBool _checked;
  final Function(bool) onChanged;
  final String label;
  final bool initialValue;
  RxCheckbox({this.onChanged, this.label, this.initialValue = false}) {
    _checked = RxBool(initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() => Padding(
          padding: const EdgeInsets.only(right: DEFAULT_PADDING_VALUE, top: DEFAULT_PADDING_VALUE, bottom: DEFAULT_PADDING_VALUE),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _checked.value,
              onChanged: (checked) {
                if (onChanged != null) {
                  onChanged(checked);
                }
                _checked.value = checked;
              },
            ),
          ),
        )),
        Text(label ?? '')
      ],
    );
  }
}
