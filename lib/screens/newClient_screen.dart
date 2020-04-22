//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewClientScreen extends StatefulWidget {
  @override
  _NewClientScreenState createState() => _NewClientScreenState();
}

class _NewClientScreenState extends State<NewClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adressController = TextEditingController();
  String selectedGender;

//    final _passController = TextEditingController();
//    final _rePassController = TextEditingController();
//    File _image;

//  String _uploadedFileURL;

//    Future chooseFile() async {
//      print('selecionando imagem');
//      await Ima.pickImage(source: ImageSource.gallery).then((image) {
//        setState(() {
//          _image = image;
//          print('imagem selecionada');
//        });
//        _scaffoldKey.currentState.showSnackBar(SnackBar(
//          content: Text('imagem Selecionada'),
//          backgroundColor: Colors.orange,
//          duration: Duration(seconds: 2),
//        ));
//      });
//    }

  void saveClient() async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Cliente criado com sucesso!'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));

    Map<String, dynamic> data = {
      'name': _nameController.text + ' ' + _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'adress': _adressController.text
    };
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection('users').add(data).then((value) {
      Map<String, dynamic> userUid = {
        'uidUser': value.documentID,
      };
      print('salvou');
      Firestore.instance
          .collection('companies')
          .document(user.uid)
          .collection('clients')
          .add(userUid);
      print('salvou2');
    });
    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Criar usuário',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
//                Row(
//                  children: <Widget>[
//                    Container(
//                      padding: EdgeInsets.only(right: 12.0),
//                      decoration: new BoxDecoration(
//                          border: new Border(
//                              right: new BorderSide(
//                                  width: 1.0, color: Colors.white24))),
//                      child: Hero(
//                          tag: 'newAvatar',
//                          child: _image == null
//                              ? CircleAvatar(
//                              radius: 60,
//                              backgroundColor: Colors.grey.withAlpha(100),
//                              child: IconButton(
//                                icon: Icon(
//                                  Icons.photo_camera,
//                                  color: Colors.blueAccent,
//                                ),
//                                onPressed: () {
//                                  print('tirar foto');
//                                  chooseFile();
//                                },
//                              ))
//                              : CircleAvatar(
//                              radius: 60,
//                              backgroundColor: Colors.grey.withAlpha(100),
//                              backgroundImage: FileImage(_image),
////                                      NetworkImage(_uploadedFileURL),
//                              child: InkWell(
//                                onTap: () {
//                                  chooseFile();
//                                },
//                              ))),
//                    ),
            Container(
              padding: EdgeInsets.only(left: 20.0),
              width: 200,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        hintText: "Nome",
                        labelStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.person)),
                    validator: (text) {
                      if (text.isEmpty) {
                        return "Nome inválido";
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      hintText: "Sobrenome",
                      labelStyle: TextStyle(color: Colors.white),
                      icon: Icon(Icons.person_outline),
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return "Nome inválido";
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
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
              keyboardType: TextInputType.text,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.edit,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 10,
                ),
                DropdownButton(
//                      style: _fieldStyle,
                  items: <String>['Masculino', 'Feminino'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  value: selectedGender,
                  isExpanded: false,
                  hint: new Text(
                    'Genero                                               ',
//                        style: _fieldStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 32.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text('Criar cliente'),
          backgroundColor: Colors.blueAccent,
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              saveClient();
            }
          }),
    );
  }
}
