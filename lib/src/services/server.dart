import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Server {
  String host = 'http://192.168.100.47:4000';

  Future<Map> get(String route) async {
    route = "$host$route";
    http.Response response = await http.get(route);
    print(response);
    Map data = await json.decode(response.body);
    return data;
  }

  Future<Map> post(String route, dynamic data) async {
    route = "$host$route";
    http.Response response = await http.post(
      route,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    Map res = json.decode(response.body);
    print(res);
    return res;
  }

  Future postImage(String route, dynamic formData) async {
    try {
      route = "$host$route";
      Dio dio = new Dio();
      var response = await dio.post(route,
          data: formData,
          options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            },
          ));
      return response;
    } catch (e) {
      print("Error request post Image $e");
      return {"data": false};
    }
  }
}
