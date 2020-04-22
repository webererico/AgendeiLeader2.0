class ProfileValidators{

  String validateName(String text){
  print('valido');
  return null;
  }
  String validateCNPJ(String text){
    print('valido');
    return null;
  }
  String validateEmail(String text){
    print('valido');
    return null;
  }
  String validatePhone(String text){
    print('valido');
    return null;
  }
  String validateAdress(String text){
    print('valido');
    return null;
  }
  String validateNameBoss(String text){
    print('valido');
    return null;
  }
  String validateCPF(String text){
    print('valido');
    return null;
  }
  String validadePass(String pass){
    if(pass.isEmpty || pass.length<6){
      return 'senha inválida. Informe sua senha para alterar seus dados.';
    }else{
      print('valido');
      return null;
    }
  }


}