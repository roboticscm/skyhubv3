import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/util/form_item.dart';

class SIntFormField extends StatelessWidget {
  final Rx<FormItemInt> formItem$;
  TextEditingController _controller;
  final String label;
  final bool required;
  final int initialValue;

  SIntFormField({this.formItem$, this.label, this.required = false, this.initialValue}) {
    _controller = TextEditingController(text: "$initialValue");
    _controller.addListener(() {
      final intValue = int.tryParse(_controller.text.trim()) ?? 0;
      formItem$.value = FormItemInt(value: intValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            errorText: formItem$.value.error,
            labelText: "${label ?? ''} ${(required ?? false) ? '*' : ''}",
          ),
        ));
  }
}
