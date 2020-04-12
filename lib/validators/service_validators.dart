class ServiceValidators{

  String validateName(String text){
    if(text.isEmpty) return "Preencha o nome do serviço";
    print('nome válido');
    return null;
  }
  String validateDescription(String text){
    if(text.isEmpty) return "Por favor, infome a descrição do serviço";
    print('descricao válido');
    return null;
  }
  String validatePrice(String text){
    print('entrouPrice');
    print(text);
    double price = double.tryParse(text);
    print(price);
    if(text!= null){
      if(!text.contains(".") || text.split((".")[0]).length!=2)
        return "Utilize duas casas decimais";
    }else{
      return "O preço informado é inválido";
    }
    print('preco válido');
    return null;
  }
  String validateDuration(String text){
    print('entrouDuration');
    int min = int.tryParse(text);
    if(min!=null){
      if(text.contains('.')|| min>720)
        return "Valor informado fora do padrão.";
    }else{
      return "Informe um valor em minutos";
    }
    print('duracao válido');
    return null;
  }
}