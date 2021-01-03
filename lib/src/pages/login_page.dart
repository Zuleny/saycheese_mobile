import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'package:saycheese_mobile/src/bloc/login_bloc.dart';
import 'package:saycheese_mobile/src/bloc/provider.dart';
import 'package:saycheese_mobile/src/pages/home_page.dart';
import 'package:saycheese_mobile/src/services/server.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';
import 'package:saycheese_mobile/src/pages/customer_photography_management/customer/customer_register_page.dart';

class LoginPage extends StatefulWidget {
  static final String routeName = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Server serverInstance = new Server();

  final prefs = new Preferences();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        _createFont(context),
        _loginForm(context),
      ],
    ));
  }

  Widget _loginForm(BuildContext context) {
    final bloc = Provider.of(context);
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SafeArea(child: Container(height: 160.0)),
          Container(
            width: size.width * 0.85,
            margin: EdgeInsets.symmetric(vertical: 20.0),
            padding: EdgeInsets.symmetric(vertical: 50.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: Offset(0.0, 5.0))
                ]),
            child: Column(
              children: <Widget>[
                Text('Inicio de Sesión',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 60.0),
                _createEmail(bloc),
                SizedBox(height: 30.0),
                _createPassword(bloc),
                SizedBox(height: 30.0),
                _createLogIn(context, bloc)
              ],
            ),
          ),
          _createButtonRegisterOwner(context),
          SizedBox(height: 100.0)
        ],
      ),
    );
  }

  Widget _createButtonRegisterOwner(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: Color(0xFF4CBD77),
      textColor: Colors.white,
      child: Text("Crear cuenta nueva"),
      onPressed: () {
        Navigator.pushNamed(context, Customer.routeName);
      },
    );
  }

  Widget _createLogIn(BuildContext context, LoginBloc bloc) {
    return StreamBuilder(
        stream: bloc.formValidStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
            child: Container(
              child: Text('Iniciar Sesión'),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 5.0,
            color: Colors.deepPurple,
            textColor: Colors.white,
            onPressed: snapshot.hasData
                ? () async {
                    String message =
                        await _verifyLogin(bloc.email, bloc.password);
                    if (message == "") {
                      Navigator.pushReplacementNamed(
                          context, HomePage.routeName);
                    } else {
                      _showToast("Login Incorrect: $message", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                    }
                  }
                : null,
          );
        });
  }

  Widget _createEmail(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                icon: Icon(Icons.alternate_email,
                    color: prefs.getColor(prefs.color)),
                hintText: 'example@gmail.com',
                labelText: 'Email',
                counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: (value) => bloc.changeEmail(value),
          ),
        );
      },
    );
  }

  Widget _createPassword(LoginBloc bloc) {
    return StreamBuilder(
      stream: bloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
                icon: Icon(Icons.lock_outline,
                    color: prefs.getColor(prefs.color)),
                labelText: 'Contraseña',
                counterText: snapshot.data,
                errorText: snapshot.error),
            onChanged: bloc.changePassword,
          ),
        );
      },
    );
  }

  Widget _createFont(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final purpleFont = Container(
      height: size.height,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: <Color>[Color(0xFFCAA6F0), Colors.deepPurple],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight)),
    );
    final circles = Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(255, 255, 255, 0.05)));
    return Stack(
      children: <Widget>[
        purpleFont,
        Positioned(top: 90.0, left: 20.0, child: circles),
        Positioned(top: -40.0, right: -30.0, child: circles),
        Positioned(bottom: -50.0, right: -10.0, child: circles),
        Positioned(bottom: 120.0, right: 20.0, child: circles),
        Positioned(bottom: -50.0, left: -20.0, child: circles),
        Container(
          padding: EdgeInsets.only(top: 70.0),
          child: Column(
            children: <Widget>[
              Icon(Icons.camera_alt_outlined, color: Colors.white, size: 100.0),
              SizedBox(height: 2.0, width: double.infinity),
              Text('SayCheese!',
                  style: TextStyle(color: Colors.white, fontSize: 25.0))
            ],
          ),
        )
      ],
    );
  }

  Future<String> _verifyLogin(email, password) async {
    try {
      final key = encrypt.Key.fromLength(16);
      final iv = encrypt.IV.fromLength(8);
      final encrypter = encrypt.Encrypter(encrypt.Salsa20(key));

      final encrypted = encrypter.encrypt(password, iv: iv);
      //final decrypted = encrypter.decrypt(encrypted, iv: iv);
      print(encrypted.base16);

      var values = {"email": email, "password": password};
      print("email : $email pass: ${encrypted.base16}");
      Map data = await serverInstance.post('/api/customer_auth/signin', values);
      print(data['token']);
      if (data['token'] == "") return data['message'];
      return "";
    } catch (e) {
      print("Error Login: $e");
      return "error";
    }
  }

  void _showToast(String msg, BuildContext context,
      {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
