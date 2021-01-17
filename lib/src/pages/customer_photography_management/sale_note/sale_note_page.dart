import 'package:flutter/material.dart';
import 'package:saycheese_mobile/src/bloc/provider.dart';
import 'package:saycheese_mobile/src/pages/home_page.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';
import 'package:saycheese_mobile/src/services/stripe_payment.dart';
import 'package:saycheese_mobile/src/bloc/login_bloc.dart';

class SaleNote extends StatefulWidget {
  static final String routeName = 'sale_note';
  List shoppingCart;
  int eventCode;
  String eventName;
  String studioName;
  String coordinatorName;
  double totalCost;
  int quantityImage;

  SaleNote(dataI, eventCodeI, eventNameI, studioNameI, coordinatorNameI,
      totalCostI, quantityImagesI) {
    this.shoppingCart = dataI;
    this.eventCode = eventCodeI;
    this.eventName = eventNameI;
    this.studioName = studioNameI;
    this.coordinatorName = coordinatorNameI;
    this.totalCost = totalCostI;
    this.quantityImage = quantityImagesI;
  }
  @override
  _SaleNoteState createState() => _SaleNoteState();
}

class _SaleNoteState extends State<SaleNote> {
  final prefs = new Preferences();
  final bucketUrl = "https://bucket-saycheese.s3.amazonaws.com/profiles";
  List shoppingCart = [];
  bool _print = false;
  int quantityPhotosShoppingCart = 0;

  @override
  void initState() {
    setData(this.widget.shoppingCart);
    super.initState();
  }

  setData(var data) {
    shoppingCart = data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("Checkout"),
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
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Text(
              "Detalles de Compra",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          _getDivider(),
          _getDetail("Cliente", Provider.of(context).email),
          _getDetail("Evento", this.widget.eventName),
          _getDetail("Coordinador", this.widget.coordinatorName),
          _getDetail("Estudio", this.widget.studioName),
          _getDivider(),
          _getDetail("Cant. Imagenes", this.widget.quantityImage.toString()),
          _getDetail("Total a pagar", "Bs. ${this.widget.totalCost}"),
          _getCheckPrint(),
          _getButtonPayment()
        ],
      ),
    );
  }

  Widget _getDivider() {
    return Divider(
      color: Colors.black45,
      endIndent: 20,
      indent: 20,
    );
  }

  Widget _getDetail(String key, String value) {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            Text(
              "$key:   ",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.grey),
              textAlign: TextAlign.start,
            ),
            Text(
              "$value",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.deepPurple,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.end,
            ),
          ],
        ));
  }

  Widget _getCheckPrint() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          'Lo quiero impreso!',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.black45),
        ),
        value: _print,
        onChanged: (value) {
          setState(() {
            _print = !_print;
          });
        },
        activeColor: Color(0xFF3EBD69),
      ),
    );
  }

  Widget _getButtonPayment() {
    return RaisedButton.icon(
      icon: Icon(
        Icons.payment,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: Color(0xFF3EBD69),
      onPressed: () => _toPay(context),
      label: Text(
        "Ir a Pagar",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white),
      ),
    );
  }

  _toPay(BuildContext context) async {
    StripeClient stripeClient = new StripeClient();
    stripeClient.init();
    String totalCost = (this.widget.totalCost * 100).floor().toString();
    final response = await stripeClient.paymentWithNewCard(
        amount: totalCost, currency: 'USD');
    if (response.success) {
      _showDialog(context,
          "Pago de Bs. ${this.widget.totalCost} realizado exitosamente!\nSe ha enviado un enlace de descarga al correo ${Provider.of(context).email}");
    } else {
      _showDialog(context,
          "Pedimos disculpas, a ocurrido un error al realizar el pago.\nIntente nuevamente :)");
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
                  Navigator.pushNamed(context, HomePage.routeName);
                },
                child: Text("Ok"))
          ],
        );
      },
    );
  }
}
