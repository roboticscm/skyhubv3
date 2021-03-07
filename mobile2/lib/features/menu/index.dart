import 'package:flutter/material.dart';

class MenuTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu App Bar'),),
        body: Center(
      child: Text('Menu Content'),
    ));
  }
}
