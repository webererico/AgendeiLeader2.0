import 'dart:async';

class LoginValidators {
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink){
      if(email.contains('@')){
        sink.add(email);
      }else{
        sink.addError('Insira um e-mail válido');
      }
    }
  );

  final validatePass = StreamTransformer<String, String>.fromHandlers(
    handleData: (pass, sink){
      if(pass.length>6){
        sink.add(pass);
      }else{
        sink.addError('Senha inválida. Deve conter no mínimo 6 caracteres');
      }
    }
  );

}