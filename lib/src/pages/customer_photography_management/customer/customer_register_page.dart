import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:saycheese_mobile/src/pages/login_page.dart';
import 'package:saycheese_mobile/src/services/server.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';

class Customer extends StatefulWidget {
  static final String routeName = 'customer';

  @override
  _Customer createState() => _Customer();
}

class _Customer extends State<Customer> {
  final prefs = new Preferences();
  Server serverInstance = new Server();
  List _listOptions = ['SC', 'CB', 'BN', 'LP', 'TJ', 'PD', 'OR', 'PO', 'CH'];
  String ci = "";
  String issuedPlace = 'SC';
  String name = "";
  String phone = "";
  String email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
/*
 * 
 */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("Registro de clientes"),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                    prefs.getColor(prefs.color),
                    prefs.getSecondaryColor(prefs.color)
                  ])),
            )),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          children: <Widget>[
            _createInputName(),
            _createInputPhone(),
            _createInputEmail(),
            _createInputCi(),
            _dropDown(),
            Divider(
              color: Colors.deepPurple,
            ),
            _button(),
          ],
        ));
  }

  Widget _dropDown() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Icon(Icons.perm_identity),
      Text('Lugar de Expedido del CI: '),
      DropdownButton(
          value: issuedPlace,
          items: getListOptions(),
          onChanged: (opt) {
            setState(() {
              issuedPlace = opt;
            });
          })
    ]);
  }

  List<DropdownMenuItem<String>> getListOptions() {
    List<DropdownMenuItem<String>> list = new List();
    _listOptions.forEach((element) {
      list.add(new DropdownMenuItem(
        child: Text("$element"),
        value: element,
      ));
    });
    return list;
  }

  Widget _createInputName() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            counter: Text("letras: ${name.length}"),
            hintText: "Escribe tu Nombre",
            labelText: "Nombre",
            helperText: "Name Here",
            icon: Icon(
              Icons.person,
              color: prefs.getColor(prefs.color),
            )),
        onChanged: (val) {
          setState(() {
            name = val;
          });
        },
      ),
    );
  }

  Widget _createInputPhone() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.phone,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            counter: Text("letras: ${phone.length}"),
            hintText: "Escribe tu número telefónico",
            labelText: "Teléfono",
            helperText: "Phone Here",
            icon:
                Icon(Icons.phone_android, color: prefs.getColor(prefs.color))),
        onChanged: (val) {
          setState(() {
            phone = val;
          });
        },
      ),
    );
  }

  Widget _createInputEmail() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            counter: Text("letras: ${email.length}"),
            hintText: "Escribe tu email",
            labelText: "Email",
            helperText: "Email Here",
            icon: Icon(Icons.mail, color: prefs.getColor(prefs.color))),
        onChanged: (val) {
          setState(() {
            email = val;
          });
        },
      ),
    );
  }

  Widget _createInputCi() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            counter: Text("letras: ${ci.length}"),
            hintText: "Escribe tu CI",
            labelText: "CI",
            helperText: "CI Here",
            icon:
                Icon(Icons.featured_video, color: prefs.getColor(prefs.color))),
        onChanged: (val) {
          setState(() {
            ci = val;
          });
        },
      ),
    );
  }

  Widget _button() {
    return RaisedButton(
      textColor: Colors.white,
      color: Colors.green,
      splashColor: Colors.grey,
      shape: StadiumBorder(),
      child: Text("Registrar Cuenta"),
      onPressed: () => _registerOwner(context),
    );
  }

  _registerOwner(BuildContext context) async {
    try {
      final key = encrypt.Key.fromLength(16);
      final iv = encrypt.IV.fromLength(8);
      final encrypter = encrypt.Encrypter(encrypt.Salsa20(key));

      final encrypted = encrypter.encrypt(ci, iv: iv);
      //final decrypted = encrypter.decrypt(encrypted, iv: iv);
      print(encrypted.base16);
      var values = {
        'ci': ci,
        'issuedPlaced': issuedPlace,
        'name': name,
        'phone': phone,
        'email': email,
        'pass': encrypted.base16
      };
      Map data =
          await serverInstance.post("/owner_management/owner_manage/", values);
      var val = data['owner'];
      String message = "";
      if (val) {
        message = "Owner with CI $ci Saved Successfully!";
        _showDialog(context, message);
      } else {
        message = "Owner Register Fail!  Try later!";
        _showDialog(context, message);
      }
    } catch (e) {
      print(e);
    }
  }

  _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text("Notificación"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("$message"),
            ],
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, LoginPage.routeName);
                },
                child: Text("Ok"))
          ],
        );
      },
    );
  }
}
