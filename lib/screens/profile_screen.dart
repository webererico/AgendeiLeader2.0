import 'dart:io';

import 'package:agendei/blocs/profile_bloc.dart';
import 'package:agendei/validators/profile_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String uidCompany;
  final DocumentSnapshot company;

  ProfileScreen({this.uidCompany, this.company, Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState(uidCompany, company);
}

class _ProfileScreenState extends State<ProfileScreen> with ProfileValidators {
  FirebaseAuth auth = FirebaseAuth.instance;
  String uidCompany = '';
  Future<DocumentSnapshot> snapshot;
  File _image;
  String _uploadedFileURL;
  String newUploaded;
  List<DropdownMenuItem> categoryNames = [];

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
      uploadFile();
    });
  }

  Future uploadFile() async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://loja-f7ade.appspot.com');
    StorageReference storageReference =
        _storage.ref().child('companies/${DateTime.now()}.png');
    StorageUploadTask uploadTask = storageReference.putFile(_image);

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        'carregando imagem...',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      duration: Duration(minutes: 1),
    ));
    await uploadTask.onComplete;
    _scaffoldKey.currentState.removeCurrentSnackBar();

    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
        newUploaded = fileURL;
        _profileBloc.saveImg(_uploadedFileURL);
      });
    });
  }

  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uidCompany = user.uid.toString();
    return uidCompany;
  }

  checkCategory() async {
    final DocumentSnapshot company = await Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .get();
    return company.data['uidCategory'].toString();
  }

  @override
  void initState() {
    getUID().then((results) {
      setState(() {
        uidCompany = results;
      });
    });
    checkCategory().then((results) {
      setState(() {
        selectedCategory = results;
      });
    });
    print(selectedCategory);
    super.initState();
  }

  final ProfileBloc _profileBloc;
  final _formkey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedCategory;

  _ProfileScreenState(String uidCompany, DocumentSnapshot company)
      : _profileBloc = ProfileBloc(uidCompany: uidCompany, company: company);

  @override
  Widget build(BuildContext context) {

    final _fieldStyle = TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    );

    InputDecoration _buildDecoration(String label) {

      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0.0,
        title: Text('Editar perfil da empresa'),
        actions: <Widget>[
          StreamBuilder<bool>(
              stream: _profileBloc.outCreated,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return StreamBuilder<bool>(
                      stream: _profileBloc.outLoading,
                      initialData: false,
                      builder: (context, snapshot) {
                        return IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              return showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Apagar Empresa?'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(
                                              'Apagando o perfil de empresa, todos seus dados serão removidos do sistema, incluindo calendários, serviços, agendamentos e pagamentos',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Voltar'),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            _profileBloc.deleteCompany();
                                          },
                                          child: Text(
                                            'Apagar Definitivamente',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      ],
                                    );
                                  });
                            });
                      });
                } else {
                  return Container();
                }
              }),
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
          stream: _profileBloc.outLoading,
          initialData: false,
          builder: (context, snapshot) {
            return FloatingActionButton(
              tooltip: 'Savlar',
              backgroundColor: Colors.green,
              onPressed: () {
                saveProfile();
              },
              child: Icon(Icons.save),
            );
          }),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formkey,
            child: StreamBuilder<Map>(
                stream: _profileBloc.outData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
//                  categoryNames.clear();
//                  verifyCategory(snapshot.data['uidCategory']);
                  return ListView(
                    padding: EdgeInsets.all(16.0),
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Hero(
                                tag: 'newAvatar',
                                child: snapshot.data['img'] == null
                                    ? CircleAvatar(
                                        radius: 60,
                                        backgroundColor:
                                            Colors.grey.withAlpha(100),
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
                                        backgroundColor:
                                            Colors.grey.withAlpha(100),
                                        backgroundImage: NetworkImage(
                                            newUploaded == null
                                                ? snapshot.data['img']
                                                : newUploaded),
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
                              initialValue: snapshot.data['name'],
                              style: _fieldStyle,
                              decoration: _buildDecoration('Nome da Empresa'),
                              onSaved: _profileBloc.saveName,
                              validator: validateName,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: snapshot.data['cnpj'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('CNPJ da empresa'),
                        onSaved: _profileBloc.saveCNPJ,
                        validator: validateCNPJ,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['email'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('Email da empresa'),
                        onSaved: _profileBloc.saveEmail,
                        validator: validateEmail,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['adress'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('Endereço da empresa'),
                        onSaved: _profileBloc.saveAdress,
                        validator: validateAdress,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['phone'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('Telefone da empresa'),
                        onSaved: _profileBloc.savePhone,
                        validator: validatePhone,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['fullNameBoss'],
                        style: _fieldStyle,
                        decoration:
                            _buildDecoration('Nome do responsável da empresa'),
                        onSaved: _profileBloc.saveFullNameBoss,
                        validator: validateNameBoss,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['cpfBoss'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('CNPJ da empresa'),
                        onSaved: _profileBloc.saveCpfBoss,
                        validator: validateCPF,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.category,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 50.0,
                          ),
                          DropdownButton(
                            items: categoryNames,
                            onChanged: (value) {
                              setState(() {
                                print('categoria selecionada: ' + value);
                                selectedCategory = value;
                              });
                              _profileBloc.saveUidCategory(value);
                            },
                            value: selectedCategory,
                            isExpanded: false,
                            hint: Text(
                              'Escola a categoria',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
          ),
          StreamBuilder(
              stream: _profileBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: !snapshot.data,
                  child: Container(
                    color: snapshot.data ? Colors.black54 : Colors.transparent,
                  ),
                );
              }),
        ],
      ),
    );
  }

  void saveProfile() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Atualizando dados da empresa...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(minutes: 1),
      ));
      bool success = await _profileBloc.saveCompany(uidCompany);
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          success ? 'Dados atualizados com sucesso!' : 'Erro ao salvar serviço',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 60),
        onVisible: () {
          Future.delayed(Duration(seconds: 3));
          Navigator.of(context).pop();
        },
      ));
    }
  }
}
