import 'dart:async';

class Validator {
  
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink){
      Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = new RegExp(pattern);
      if (regExp.hasMatch(email)) {
        sink.add(email);
      }else{
        sink.addError('Email no Validated');
      }
    }
  );

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink){
      if (password.length>5) {
        sink.add(password);
      } else {
        sink.addError('Incorrect Password');
      }
    }
  );
}