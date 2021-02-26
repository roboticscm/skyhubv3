import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/util/form_item.dart';

class STextFormField extends StatelessWidget {
  final Rx<FormItemString> formItem$;
  TextEditingController _controller;
  final String label;
  final bool required;
  final String initialValue;

  STextFormField({this.formItem$,  this.label, this.required = false, this.initialValue}) {
    _controller = TextEditingController(text: initialValue);
    formItem$.value = FormItemString(value: initialValue);
    _controller.addListener(() {
      formItem$.value = FormItemString(value: _controller.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            errorText: formItem$.value.error,
            labelText: "${label ?? ''} ${(required ?? false) ? '*' : ''}",
          ),
        ));
  }
}
