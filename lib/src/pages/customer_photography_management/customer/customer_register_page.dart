import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import 'package:saycheese_mobile/src/pages/login_page.dart';
import 'package:saycheese_mobile/src/services/server.dart';
import 'package:saycheese_mobile/src/services/aws-s3.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';

class Customer extends StatefulWidget {
  static final String routeName = 'customer';

  @override
  _Customer createState() => _Customer();
}

class _Customer extends State<Customer> {
  final prefs = new Preferences();
  Server serverInstance = new Server();
  AwsS3 awsS3Instance = new AwsS3();
  String name = "";
  String email = "";
  String password = "";
  File _image1;
  File _image2;
  File _image3;
  final _picker = ImagePicker();

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
      body: Builder(
          builder: (context) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: Column(
                  children: <Widget>[
                    _createInputName(),
                    _createInputEmail(),
                    _createInputPassword(),
                    _showImage(context, 1),
                    _showImage(context, 2),
                    _showImage(context, 3),
                    Divider(
                      color: Colors.deepPurple,
                    ),
                    _button(),
                  ],
                ),
              )),
    );
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
            helperText: "Nombre Aqui",
            icon: Icon(
              Icons.person_outline,
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
            helperText: "Email Aqui",
            icon: Icon(Icons.mail_outline, color: prefs.getColor(prefs.color))),
        onChanged: (String val) async {
          setState(() {
            email = val;
          });
        },
      ),
    );
  }

  Widget _createInputPassword() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            counter: Text("letras: ${password.length}"),
            hintText: "Escribe una contraseña",
            labelText: "Contraseña",
            helperText: "Contraseña Aqui",
            icon: Icon(Icons.lock_outline, color: prefs.getColor(prefs.color))),
        onChanged: (val) {
          setState(() {
            password = val;
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
      onPressed: () {
        Toast.show("Registrando espere...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        _registerCustomer(context);
      },
    );
  }

  _registerCustomer(BuildContext context) async {
    try {
      String profile1 = await awsS3Instance.uploadFile(_image1);
      print("upload image 1 with id: $profile1");
      String profile2 = await awsS3Instance.uploadFile(_image2);
      print("upload image 2 with id: $profile2");
      String profile3 = await awsS3Instance.uploadFile(_image3);
      print("upload image 3 with id: $profile3");

      var values = {
        'name': name,
        'email': email,
        'password': password,
        'first_profile': profile1,
        'second_profile': profile2,
        'third_profile': profile3
      };
      Map data = await serverInstance.post("/api/customer", values);

      var customerData = data['data'];
      print("Status: $customerData");

      if (customerData == 0) {
        _showDialog(context,
            "Error: las fotos pertenecen a diferentes personas\nNota: Debes tomarte fotos donde solo tu aparezcas!");
      } else if (customerData == -1) {
        _showDialog(context,
            "Error: ocurrió un problema al registrar, intente nuevamente");
      } else {
        _showDialog(context,
            "Registro Correto\nID: ${customerData['customer_id']}\nNombre: ${customerData['name']}\nEmail: ${customerData['email']} ");
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

  Future _onImageButtonPressed(
      ImageSource source, BuildContext context, int numberImage) async {
    try {
      print("_onImageButtonPressed");
      var pickedFile = await _picker.getImage(source: source, imageQuality: 70);
      print("object: " + pickedFile.path);
      if (numberImage == 1) {
        if (pickedFile != null) {
          setState(() {
            _image1 = File(pickedFile.path);
          });
        }
      } else if (numberImage == 2) {
        if (pickedFile != null) {
          setState(() {
            _image2 = File(pickedFile.path);
          });
        }
      } else {
        if (pickedFile != null) {
          setState(() {
            _image3 = File(pickedFile.path);
          });
        }
      }
      print("Done");
    } catch (e) {
      print("Error in pickImage rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr" + e);
    }
  }

  Widget _showImage(BuildContext context, int numberImage) {
    return GestureDetector(
      onTap: () {
        final snackBar = _getSnackBarOptions(numberImage, context);
        Scaffold.of(context).showSnackBar(snackBar);
      },
      child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                color: prefs.getColor(Colors.black45),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(blurRadius: 6.0, offset: Offset(0.0, 5.0))
                ]),
            child: _getImage(numberImage),
          )),
    );
  }

  Widget _getImage(int numberImage) {
    if (numberImage == 1 && _image1 != null)
      return Image.file(File(_image1.path));
    if (numberImage == 2 && _image2 != null)
      return Image.file(File(_image2.path));
    if (numberImage == 3 && _image3 != null)
      return Image.file(File(_image3.path));

    return Image(image: AssetImage('assets/add-image.png'));
  }

  Widget _getSnackBarOptions(int numberImage, BuildContext context) {
    return SnackBar(
      backgroundColor: Colors.deepPurple[50],
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _getButtonCamera(numberImage, context),
          _getButtonGalery(numberImage, context)
        ],
      ),
    );
  }

  Widget _getButtonCamera(int numberImage, BuildContext context) {
    return IconButton(
      iconSize: 35,
      icon: Icon(
        Icons.add_a_photo_outlined,
        color: Colors.deepPurple,
      ),
      onPressed: () async {
        print("obteniendo imagen $numberImage");
        await _onImageButtonPressed(ImageSource.camera, context, numberImage);
      },
    );
  }

  Widget _getButtonGalery(int numberImage, BuildContext context) {
    return IconButton(
      iconSize: 35,
      icon: Icon(
        Icons.image_search_outlined,
        color: Colors.deepPurple,
      ),
      onPressed: () async {
        print("obteniendo imagen $numberImage");
        await _onImageButtonPressed(ImageSource.gallery, context, numberImage);
      },
    );
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image1 = File(response.file.path);
      });
    } else {
      print(response.exception.code);
    }
  }
}
