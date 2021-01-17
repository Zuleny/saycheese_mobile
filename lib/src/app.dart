import 'package:flutter/material.dart';
import 'package:saycheese_mobile/src/pages/customer_photography_management/customer/customer_register_page.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';

import 'package:saycheese_mobile/src/bloc/provider.dart';
import 'package:saycheese_mobile/src/pages/home_page.dart';
import 'package:saycheese_mobile/src/pages/login_page.dart';
import 'package:saycheese_mobile/src/pages/setting_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefs = new Preferences();
    return Provider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RestTeam',
        initialRoute: LoginPage.routeName,
        routes: {
          HomePage.routeName: (BuildContext context) => HomePage(),
          SettingPage.routeName: (BuildContext context) => SettingPage(),
          LoginPage.routeName: (BuildContext context) => LoginPage(),
          Customer.routeName: (BuildContext context) => Customer(),
          //CheckOut.routeName: (BuildContext context) => CheckOut()
        },
        theme: ThemeData(primaryColor: prefs.getColor(prefs.color)),
      ),
    );
  }
}
