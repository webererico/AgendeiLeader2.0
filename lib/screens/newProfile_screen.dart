import 'dart:io';

import 'package:agendei/blocs/login_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class NewProfile extends StatefulWidget {
  @override
  _NewProfileState createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adressController = TextEditingController();
  final _passController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _nameBossController = TextEditingController();
  final _cpfBossController = TextEditingController();
  final _rePassController = TextEditingController();
  final _loginBloc = LoginBloc();
  String selectedCategory;

  File _image;
  String _uploadedFileURL;

  Future chooseFile() async {
    print('selecionando imagem');
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
        print('imagem selecionada');
      });
      uploadFile();
    });
  }

  Future uploadFile() async {
    print('carregando imagem');
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        'Salvano imagem...',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 3),
    ));
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://loja-f7ade.appspot.com');
    StorageReference storageReference =
        _storage.ref().child('companies/${DateTime.now()}.png');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0.0,
        title: Text('Perfil da Empresa'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(21.0),
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.white24))),
                  child: Hero(
                      tag: 'newAvatar',
                      child: _uploadedFileURL == null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.withAlpha(100),
                              child: IconButton(
                                icon: Icon(
                                  Icons.photo_camera,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  print('tirar foto');
                                  chooseFile();
                                },
                              ))
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.withAlpha(100),
                              backgroundImage: NetworkImage(_uploadedFileURL),
                              child: InkWell(
                                onTap: () {
                                  chooseFile();
                                },
                              ))),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  width: 200,
                  child: TextFormField(
                    maxLength: 20,
                    controller: _nameController,
                    decoration: InputDecoration(
                        hintText: "Nome da Empresa",
                        labelStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.business)),
                    validator: (text) {
                      if (text.isEmpty) {
                        return "Nome inválido";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: _emailController,
              decoration:
                  InputDecoration(hintText: "E-mail", icon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
              validator: (text) {
                if (text.isEmpty || !text.contains("@")) {
                  return "E-mail inválido";
                } else {
                  return null;
                }
              },
            ),
            SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                  hintText: "Telefone", icon: Icon(Icons.phone)),
              keyboardType: TextInputType.number,
              validator: (text) {
                if (text.isEmpty || text.length < 9) {
                  return "Telefone inválido";
                } else {
                  return null;
                }
              },
            ),
            SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: _adressController,
              decoration: InputDecoration(
                  hintText: "Endereço", icon: Icon(Icons.place)),
              keyboardType: TextInputType.number,
              validator: (text) {
                if (text.isEmpty) {
                  return "Endereço inválido";
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _cnpjController,
              decoration: InputDecoration(
                  hintText: "CNPJ", icon: Icon(Icons.confirmation_number)),
              keyboardType: TextInputType.number,
              validator: (text) {
                if (text.isEmpty) {
                  return "CNPJ inválido";
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _nameBossController,
              decoration: InputDecoration(
                  hintText: "Nome do Responsável", icon: Icon(Icons.person)),
              keyboardType: TextInputType.number,
              validator: (text) {
                if (text.isEmpty) {
                  return "nome inválido";
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _cpfBossController,
              decoration: InputDecoration(
                  hintText: "CPF do Responsável",
                  icon: Icon(Icons.confirmation_number)),
              keyboardType: TextInputType.number,
              validator: (text) {
                if (text.isEmpty) {
                  return "Endereço inválido";
                } else {
                  return null;
                }
              },
            ),
            SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: _passController,
              decoration:
                  InputDecoration(hintText: "Senha", icon: Icon(Icons.lock)),
              obscureText: true,
              validator: (text) {
                if (text.isEmpty || text.length < 6) {
                  return "Senha inválida";
                } else {
                  return null;
                }
              },
            ),
            SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: _rePassController,
              decoration: InputDecoration(
                  hintText: "Repetir senha", icon: Icon(Icons.lock_outline)),
              obscureText: true,
              validator: (text) {
                if (text.isEmpty || text.length < 6) {
                  return "Senha inválida";
                } else {
                  return null;
                }
              },
            ),
            SizedBox(
              height: 32.0,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Carregando');
                } else {
                  List<DropdownMenuItem> categoryItems = [];
                  for (int i = 0; i < snapshot.data.documents.length; i++) {
                    DocumentSnapshot category = snapshot.data.documents[i];
                    categoryItems.add(DropdownMenuItem(
                      child: Text(
                        category.data['name'],
                      ),
                      value: '${category.documentID}',
                    ));
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.control_point,
                        size: 25.0,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 50.0,
                      ),
                      DropdownButton(
                        items: categoryItems,
                        onChanged: (categoryValue) {
                          setState(() {
                            selectedCategory = categoryValue;
                          });
                        },
                        value: selectedCategory,
                        isExpanded: false,
                        hint: Text(
                          'Escolha a categoria de serviço',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: 44.0,
              child: RaisedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "Criar conta e avançar",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Icon(Icons.chevron_right)
                  ],
                ),
                textColor: Colors.white,
                color: Colors.blueAccent,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (_passController.text == _rePassController.text) {
                      Map<String, dynamic> userData = {
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'adress': _adressController.text,
                        'phone': _phoneController.text,
                        'cnpj': _cnpjController.text,
                        'cpfBoss': _cpfBossController.text,
                        'fullNameBoss': _nameBossController.text,
                        'uidCategory': selectedCategory,
                        'img': _uploadedFileURL,
                      };
                      if (_uploadedFileURL == null) {
                        print('imagem inválida');
                        showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                    'Sua empresa não possue logo ou imagem de pefil'),
                                content: Text(
                                    'Caso você não forneça uma imagem de perfil ou sua logo iremos colocar uma imagem padrão da empresa'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      if (selectedCategory == null) {
                                        print('categoria inválida');
                                        showDialog<void>(
                                            context: context,
                                            barrierDismissible: false,
                                            // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Sua empresa não possue uma categoria'),
                                                content: Text(
                                                    'Caso a sua empresa não se encaixe em uma destas categorias, entre em contato conosco por (55) 991344031'),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('Ok'),
                                                  ),
                                                ],
                                              );
                                            });
                                      } else {
                                        print(userData);
                                        saveProfile(userData, selectedCategory);
                                        _loginBloc.submit(
                                            email: userData['email'],
                                            pass: _passController.text);
                                      }
                                    },
                                    child: Text('Concordar'),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Voltar e escolher imagem.'),
                                  ),
                                ],
                              );
                            });
                      } else if (selectedCategory == null) {
                        print('categoria inválida');
                        showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                    'Sua empresa não possue uma categoria'),
                                content: Text(
                                    'Caso a sua empresa não se encaixe em uma destas categorias, entre em contato conosco por (55) 991344031'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Ok'),
                                  ),
                                ],
                              );
                            });
                      } else {
                        print(userData);
                        saveProfile(userData, selectedCategory);
                        _loginBloc.submit(
                            email: userData['email'],
                            pass: _passController.text);
                      }
                    } else {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('As senhas não são iguais'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ));
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveProfile(
      Map<String, dynamic> userData, String selectedCategory) async {
    if (_formKey.currentState.validate()) {
      print('salvando perfil');
      _formKey.currentState.save();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Criando perfil da empresa...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        duration: Duration(minutes: 1),
      ));
      FirebaseUser user = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: userData['email'], password: _passController.text)
              .catchError((signUpError) {
        if (signUpError is PlatformException) {
          if (signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
            showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('E-mail em uso'),
                    content: Text('Este e-mail já encontra-se em uso'),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Ok'),
                      ),
                    ],
                  );
                });
            _scaffoldKey.currentState.removeCurrentSnackBar();
          }
        }
      }))
          .user;
      Firestore.instance.collection('companies').document(user.uid);
      Firestore.instance
          .collection('companies')
          .document(user.uid)
          .setData(userData);

      Firestore.instance
          .collection('categories')
          .document(selectedCategory)
          .collection('companies')
          .document(user.uid)
          .setData({
        'uidCompany': user.uid,
      });
      print('salvou');
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Perfil Criado',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 60),
        onVisible: () {},
      ));
    }
  }
}
