import 'package:flutter/material.dart';
import 'package:skyone_mobile/extension/string.dart';

class FilterField extends StatelessWidget {
  final TextEditingController _filterController = TextEditingController();
  final Function onSearch;
  final bool realtime;

  FilterField({this.onSearch, this.realtime = true}) {
    _filterController.addListener(() {
      if(realtime && onSearch!= null) {
        onSearch(_filterController.text.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          labelText: 'COMMON.LABEL.FILTER'.t(),
          suffixIcon: InkWell(
            onTap: () {
              if(onSearch != null) {
                onSearch(_filterController.text.trim());
              }
            },
            child: const Icon(Icons.search),
          )),
      controller: _filterController,
    );
  }
}
