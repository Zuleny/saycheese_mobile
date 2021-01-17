import 'package:flutter/material.dart';
import 'package:saycheese_mobile/src/bloc/provider.dart';
import 'package:saycheese_mobile/src/pages/customer_photography_management/shopping_cart/shopping_cart_page.dart';
import 'package:saycheese_mobile/src/services/server.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';

class PhotoList extends StatefulWidget {
  static final String routeName = 'customer_photo_list';
  String data;

  PhotoList(dataI) {
    this.data = dataI;
  }
  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  final prefs = new Preferences();
  Server serverInstance = new Server();
  final bucketUrl = "https://bucket-saycheese.s3.amazonaws.com/profiles";
  int eventCode;
  String eventName;
  String coordinatorName;
  String studioName;
  List shoppingCart = [];
  int quantityPhotosShoppingCart = 0;
  List photoList = [];
  bool state = false;

  @override
  void initState() {
    setData(this.widget.data);
    super.initState();
  }

  setData(String data) {
    int index = data.indexOf(';');
    eventCode = int.parse(data.substring(0, index));
    data = data.substring(index + 1);
    int newIndex = data.indexOf(';');
    int lastIndex = data.lastIndexOf(';');
    eventName = data.substring(0, newIndex);
    coordinatorName = data.substring(newIndex + 1, lastIndex);
    studioName = data.substring(lastIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    print(photoList);
    if (photoList.length == 0 && !state) {
      _getCustomerPhotoList(bloc.email);
      state = true;
    }
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("Fotos"),
            actions: <Widget>[
              PopupMenuButton(
                elevation: 2.0,
                color: Colors.white,
                itemBuilder: (BuildContext context) {
                  return getShoppingCart(context);
                },
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                child: Text("$quantityPhotosShoppingCart",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.white)),
              )
            ],
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
        body: _getPhotoList());
  }

  Widget _getPhotoList() {
    return ListView.builder(
      padding: EdgeInsets.all(10.0),
      itemCount: photoList.length,
      itemBuilder: (BuildContext context, int index) {
        var element = photoList[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
          child: _cardImage(element),
        );
      },
    );
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
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text("Fotógrafo: ${photograph['photographer_name']}",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0,
                    color: Colors.grey)),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text("Precio: Bs. ${photograph['price']}",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.deepPurple)),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
              child: RaisedButton.icon(
                onPressed: () => addToShoppingCart(photograph),
                label: Text("Agregar a Carrito",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white)),
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                color: Color(0xFF3EBD69),
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

  addToShoppingCart(var photograph) {
    bool exist = false;
    shoppingCart.forEach((photo) {
      if (photo['name'] == photograph['name']) {
        setState(() {
          photo['quantity'] = photo['quantity'] + 1;
          quantityPhotosShoppingCart++;
        });
        exist = true;
        return;
      }
    });

    if (!exist) {
      var photographData = {
        'name': photograph['name'],
        'quantity': 1,
        'price': photograph['price'],
        'photographer_id': photograph['photographer_id']
      };
      setState(() {
        shoppingCart.add(photographData);
        quantityPhotosShoppingCart++;
      });
    }
    print("shopping cart: $shoppingCart");
  }

  _getCustomerPhotoList(String email) async {
    Map data = await serverInstance
        .get("/api/photograph/event-customer/$email°$eventCode");
    var val = data['data'];
    print("data: $val");
    print(val);
    setState(() {
      photoList = val;
    });
  }

  List<PopupMenuEntry> getShoppingCart(BuildContext context) {
    List<PopupMenuEntry> list = new List();
    list.add(new PopupMenuItem(
      child: Text("Cant.      Foto",
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.w800, fontSize: 16)),
    ));

    shoppingCart.forEach((element) {
      list.add(new PopupMenuItem(
        child: _getPhotoDetail(element),
        value: "${element['name']}",
      ));
    });
    list.add(new PopupMenuItem(
        child: FlatButton(
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ShoppingCart(shoppingCart, eventCode, eventName,
              studioName, coordinatorName))),
      child: Text("    Ver Carrito",
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.w800, fontSize: 16)),
    )));
    return list;
  }

  Widget _getPhotoDetail(var photoData) {
    return Container(
        padding: EdgeInsets.all(3),
        child: Row(
          children: [
            Text(
              "${photoData['quantity']}   ",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.deepPurple),
            ),
            ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(this.prefs.getColorFilter()),
                  child: FadeInImage(
                    placeholder: AssetImage('assets/loading-oficial.gif'),
                    image: NetworkImage('$bucketUrl/${photoData['name']}'),
                    fadeInDuration: Duration(milliseconds: 200),
                    height: 100,
                    width: 120,
                    fit: BoxFit.fill,
                  ),
                )),
          ],
        ));
  }
}
