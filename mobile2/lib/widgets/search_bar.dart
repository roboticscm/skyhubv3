import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/extensions/string.dart';

class SearchBar extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final TextEditingController controller;

  SearchBar({@required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          filled: true,
          isDense: true,
          suffixIcon: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 15,
            minHeight: 15,
          ),
          contentPadding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
          hintStyle: TextStyle(color: _themeController.getDisabledColor()),
          hintText: "SYS.LABEL.SEARCH".t,
          fillColor: _themeController.themeData.value.backgroundColor),
    );
  }
}
