import 'package:saycheese_mobile/src/pages/customer_photography_management/photograph/photo_list%20_event_page.dart';
import 'package:saycheese_mobile/src/services/server.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:saycheese_mobile/src/bloc/provider.dart';
import 'package:saycheese_mobile/src/services/share_preferences.dart';
import 'package:saycheese_mobile/src/widgets/menu_widget.dart';

class HomePage extends StatefulWidget {
  static final String routeName = 'home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final prefs = new Preferences();
  Server http = new Server();
  bool selected = false;
  bool state = false;
  List _horses = [];
  List _notifications = [];
  bool stateNotifications = false;
  String futureString = "";

  _getProductList(int ci) async {
    Map data = await http.get("/owner_management/product_manage/owner");
    var val = data['listProducts'];
    setState(() {
      _horses = val;
    });
  }

  _getNotificatonsList(int ci) async {
    Map data =
        await http.get("/owner_management/owner_manage/notifications/$ci");
    print(data);
    var val = data['notifications'];
    setState(() {
      _notifications = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    int ci = int.parse(bloc.password);
    if (_horses.length == 0 && !state) {
      _getProductList(ci);
      state = true;
    }

    if (_notifications.length == 0 && !stateNotifications) {
      _getNotificatonsList(ci);
      stateNotifications = true;
      print(_notifications);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("SayCheese"),
        actions: <Widget>[
          PopupMenuButton(
            color: Colors.white70,
            itemBuilder: (BuildContext context) {
              return _getListNotifications(context);
            },
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
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
        ),
      ),
      drawer: MenuWidget(),
      body: _getHomePageBody(context, ci),
      floatingActionButton: _createButton(context),
    );
  }

  Widget _createButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.qr_code_scanner_outlined, size: 35),
      tooltip: "Scanear Qr",
      backgroundColor: prefs.getColor(prefs.color),
      onPressed: () => _scanQR(context),
    );
  }

  _scanQR(BuildContext context) async {
    try {
      futureString = await scanner.scan();
    } catch (e) {
      futureString = e.toString();
    }
    print("futureString: $futureString");
    if (futureString != null) {
      print("There is information");
      if (validateData(futureString)) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PhotoList(futureString)));
      }
    } else {
      print("There isnt information");
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    }
  }

  bool validateData(String data) {
    try {
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Widget _getHomePageBody(BuildContext context, int ci) {
    if (_horses.length > 0 && state) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 520.0,
                  initialPage: 0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayAnimationDuration: Duration(seconds: 3),
                  enableInfiniteScroll: true,
                ),
                items: _horses.map((var e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Builder(
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment
                                      .bottomLeft, // 10% of the width, so there are ten blinds.
                                  end: Alignment.topRight, // 10% of the width, so there are ten blinds.
                                  colors: prefs.getLoginBackgroundColor()),
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 6.0,
                                    offset: Offset(2.0, 5.0))
                              ]),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                child: Image(
                                    image: NetworkImage(
                                        "${http.host}/photo/${e["product_image"]}")),
                                height: 300,
                              ),
                              Column(
                                children: <Widget>[
                                  ListTile(
                                    contentPadding: EdgeInsets.all(5),
                                    title: Text(
                                        "Marca: ${e["brand"]}, Modelo: ${e["model"]}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0,
                                            color: Colors.deepPurple)),
                                    subtitle: Text(
                                      e["description_product"],
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  ),
                                  RaisedButton.icon(
                                      icon: Icon(Icons.check),
                                      textColor: Colors.white,
                                      color: Colors.green,
                                      splashColor: Colors.grey,
                                      shape: StadiumBorder(),
                                      label: Text("Registrar"),
                                      onPressed: () => registerProductOwner(
                                          context, e["cod_product"], ci))
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            selected = !selected;
          });
        },
        child: Center(
          child: AnimatedContainer(
              width: selected ? 200.0 : 100.0,
              height: selected ? 100.0 : 200.0,
              color: selected ? prefs.getColor(prefs.color) : Colors.red,
              alignment:
                  selected ? Alignment.center : AlignmentDirectional.topCenter,
              duration: Duration(seconds: 3),
              curve: Curves.fastOutSlowIn,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.computer),
                    Text(
                      "No tienes ningun producto registrado",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )),
        ),
      );
    }
  }

  registerProductOwner(
      BuildContext context, int codProduct, int ciOwner) async {
    var data = {"cod_product": codProduct, "ci_owner": ciOwner};
    Map responseRegister = await http.post(
        "/owner_management/product_manage/owner/register_product", data);
    if (responseRegister['result'] > 0) {
      print("registred: ${responseRegister["result"]}");
      int codProductOwner = responseRegister['result'];
      _showToast("Producto $codProductOwner Registrado correctamente", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      _showToast("Producto NO Registrado, Intente Nuevamente", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _showToast(String msg, BuildContext context,
      {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  List<PopupMenuEntry<String>> _getListNotifications(BuildContext context) {
    List<PopupMenuEntry<String>> list = new List();
    _notifications.forEach((element) {
      list.add(new PopupMenuItem(
        child: Text(
          "Solicitud N° ${element['request_no']} HA CONCLUIDO,con cod. producto ${element['cod_product']}",
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        value: "${element['request_no']}",
      ));
    });
    list.add(new PopupMenuItem(
        child: FlatButton(
      /*onPressed: () =>
          //Navigator.pushNamed(context, OwnerNotification.routeName)
      ,*/
      onPressed: () {},
      child: Text("Ver Todos",
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.w800, fontSize: 14)),
    )));
    return list;
  }
}
