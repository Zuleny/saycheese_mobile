import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:saycheese_mobile/src/pages/customer_photography_management/sale_note/sale_note_page.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';

class ShoppingCart extends StatefulWidget {
  static final String routeName = 'shopping_cart';
  List shoppingCart;
  int eventCode;
  String eventName;
  String studioName;
  String coordinatorName;

  ShoppingCart(dataI, eventCodeI, eventNameI, studioNameI, coordinatorNameI) {
    this.shoppingCart = dataI;
    this.eventCode = eventCodeI;
    this.eventName = eventNameI;
    this.studioName = studioNameI;
    this.coordinatorName = coordinatorNameI;
  }
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  final prefs = new Preferences();
  final bucketUrl = "https://bucket-saycheese.s3.amazonaws.com/profiles";
  List shoppingCart = [];

  int quantityPhotosShoppingCart = 0;
  double totalCost = 0;

  @override
  void initState() {
    setData();
    super.initState();
  }

  setData() {
    shoppingCart = this.widget.shoppingCart;
    quantityPhotosShoppingCart = _getQuantityPhotos();
    totalCost = _getTotalCost();
  }

  _getTotalCost() {
    double total = 0;
    shoppingCart.forEach((element) {
      total = total + element['quantity'] * double.parse(element['price']);
    });
    return total;
  }

  _getQuantityPhotos() {
    int quantity = 0;
    shoppingCart.forEach((element) {
      quantity = quantity + element['quantity'];
    });
    return quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("Carrito de Compras"),
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
      body: _getPhotoList(),
    );
  }

  Widget _getPhotoList() {
    return ListView(
        padding: EdgeInsets.all(10.0), children: _getShoppingCart());
  }

  List<Widget> _getShoppingCart() {
    List<Widget> list = [];
    shoppingCart.forEach((element) {
      list.add(Padding(
        padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
        child: _cardImage(element),
      ));
    });
    list.add(Padding(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Container(
        child: Text(
            "\n      Cant. Imagenes:          $quantityPhotosShoppingCart\n      Total:                      Bs. $totalCost\n",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.grey)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                  offset: Offset(2.0, 10.0))
            ]),
      ),
    ));
    list.add(Padding(
      padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
      child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Color(0xFF3EBD69),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SaleNote(
                  shoppingCart,
                  this.widget.eventCode,
                  this.widget.eventName,
                  this.widget.studioName,
                  this.widget.coordinatorName,
                  totalCost,
                  quantityPhotosShoppingCart))),
          child: Text(
            "Finalizar Compra",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.white),
          )),
    ));
    return list;
  }

  Widget _cardImage(var photograph) {
    final card = Container(
      child: Column(
        children: <Widget>[
          ColorFiltered(
            colorFilter: ColorFilter.matrix(this.prefs.getColorFilter()),
            child: FadeInImage(
              placeholder: AssetImage('assets/loading-oficial.gif'),
              image: NetworkImage('$bucketUrl/${photograph['name']}'),
              fadeInDuration: Duration(milliseconds: 200),
              height: 300,
              fit: BoxFit.fill,
            ),
          ),
          Container(
              padding: EdgeInsets.all(10.0),
              child: ButtonBar(
                children: [
                  Text(
                    "Bs. ${photograph['price']}  ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.deepPurple),
                  ),
                  TextButton.icon(
                    onPressed: () => addMoreToShoppingCart(photograph),
                    icon: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.deepPurple,
                    ),
                    label: Text(""),
                  ),
                  Text(
                    "${photograph['quantity']}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Color(0xFF27C744)),
                  ),
                  TextButton.icon(
                    onPressed: () => removeToShoppingCart(photograph),
                    icon: Icon(
                      Icons.remove,
                      size: 35,
                      color: Colors.grey,
                    ),
                    label: Text(""),
                  )
                ],
              )),
        ],
      ),
    );
    return Container(
      child: ClipRRect(
        child: card,
        borderRadius: BorderRadius.circular(30.0),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 2.0,
                offset: Offset(2.0, 10.0))
          ]),
    );
  }

  addMoreToShoppingCart(var photograph) {
    shoppingCart.forEach((photo) {
      if (photo['name'] == photograph['name']) {
        setState(() {
          photo['quantity'] = photo['quantity'] + 1;
          quantityPhotosShoppingCart++;
          totalCost = totalCost + double.parse(photo['price']);
        });
        return;
      }
    });
    print("shopping cart: $shoppingCart");
  }

  removeToShoppingCart(var photograph) {
    shoppingCart.forEach((photo) {
      if (photo['name'] == photograph['name']) {
        if (photo['quantity'] > 1) {
          setState(() {
            photo['quantity'] = photo['quantity'] - 1;
            quantityPhotosShoppingCart--;
            totalCost = totalCost - double.parse(photo['price']);
          });
        }
        return;
      }
    });
    print("shopping cart: $shoppingCart");
  }
}
