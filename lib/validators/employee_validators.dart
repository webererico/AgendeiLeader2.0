class EmployeeValidators {
  String validateFullName(String text) {
    if (text.isEmpty) return 'Preenchar o nome completo do funcionário';
    print('nome  válido');
    return null;
  }

  String validateCPF(String text) {
    if (text.isEmpty) return 'Preenchar o cpf do funcionário';
    if (text.length != 11) return 'cpf informado é invalido';
    print('cpf  válido');
    return null;
  }

  String validateAdress(String text) {
    if (text.isEmpty) return 'Preenchar o endereco do funcionário';
    print('endereco  válido');
    return null;
  }

  String validatePhone(String text) {
    if (text.isEmpty) return 'Preenchar o telefone do funcionário';
    print('telefone  válido');
    return null;
  }

  String validateEmail(String text) {
    if (text.isEmpty) return 'Preenchar o email do funcionário';
    print('email  válido');
    return null;
  }

  String validateProfile(String text) {
    if (text.isEmpty) return 'Preenchar a foto do funcionário';
    print('foto  válido');
    return null;
  }

  String validateFunction(String text) {
    if (text.isEmpty) return 'Preenchar a função do funcionário';
    print('funcao  válido');
    return null;
  }

  String validateBirth(String text) {
    if (text.isEmpty) return 'Preenchar o aniverário do funcionário';
    print('função  válido');
    return null;
  }
}
