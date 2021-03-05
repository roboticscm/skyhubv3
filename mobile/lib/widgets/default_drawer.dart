import 'package:flutter/material.dart';
import 'package:skyone_mobile/features/home/settings.dart';
import 'package:skyone_mobile/the_app.dart';
import 'package:skyone_mobile/extension/string.dart';

class DefaultDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return _buildDrawer(context);
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: IconButton(
                icon: Image.asset(
                  'assets/logo.png',
                ),
                onPressed: () {}),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('COMMON.LABEL.SETTINGS'.t()),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return SettingsPage();
                  });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: Text('SYS.BUTTON.LOGOUT'.t()),
            onTap: () {
              TheApp.logout(context);
            },
          ),
        ],
      ),
    );
  }
}