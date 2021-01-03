import 'package:flutter/material.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';
import 'package:saycheese_mobile/src/widgets/menu_widget.dart';

class SettingPage extends StatefulWidget {
  static final String routeName = 'settings';

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final prefs = new Preferences();
  int _nroColor;

  @override
  void initState() {
    super.initState();
    _nroColor = prefs.color;
  }

  _getSelectedRadio(int values) {
    prefs.color = values;
    _nroColor = values;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Configuración"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                  prefs.getColor(prefs.color),
                  prefs.getSecondaryColor(prefs.color)
                ])),
          ),
        ),
        drawer: MenuWidget(),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5.0),
              child: Text('Settings', style: TextStyle(fontSize: 40.0)),
            ),
            RadioListTile(
                value: 1,
                title: Text('Purple'),
                groupValue: _nroColor,
                onChanged: _getSelectedRadio),
            Divider(),
            RadioListTile(
                value: 2,
                title: Text('Orange'),
                groupValue: _nroColor,
                onChanged: _getSelectedRadio),
            Divider(),
            RadioListTile(
                value: 3,
                title: Text('Blue'),
                groupValue: _nroColor,
                onChanged: _getSelectedRadio),
            Divider(),
            RadioListTile(
                value: 4,
                title: Text('Green'),
                groupValue: _nroColor,
                onChanged: _getSelectedRadio),
            Divider()
          ],
        ));
  }
}
