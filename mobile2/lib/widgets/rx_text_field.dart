import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/util/form_item.dart';

class RxTextField extends StatelessWidget {
  TextEditingController _editingController;
  final RxTextFieldController rxController;
  final String label;
  final bool required;
  final String initialValue;
  final bool obscureText;
  final obscureText$ = false.obs;

  RxTextField(
      {this.rxController,
      this.label,
      this.required = false,
      this.initialValue,
      this.obscureText = false})
      : assert(rxController != null) {
    obscureText$.value = obscureText;
    _editingController = TextEditingController(text: initialValue);
    if ((initialValue ?? '').length > 0) {
      rxController.value$.value = initialValue;
    } else if (required) {
      rxController.error$.value = '';
    }

    _editingController.addListener(() {
      rxController.value$.value = _editingController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()
      => TextFormField(
        controller: _editingController,
        obscureText: obscureText$.value,
        decoration: InputDecoration(
          errorText: (rxController.error$.value ?? '').length == 0 ? null : rxController.error$.value,
          labelText: "${label ?? ''} ${(required ?? false) ? '*' : ''}",
          suffixIcon: !obscureText ? null : InkWell(
            onTap: () {
              obscureText$.value = false;
              Future.delayed(Duration(seconds: 1)).then((_) => obscureText$.value = true);
            },
            child: const Icon(Icons.remove_red_eye),
          ),
        ),
      ),
    );
  }
}

class RxTextFieldController extends GetxController {
  final value$ = ''.obs;
  final error$ = RxString(null);
}
