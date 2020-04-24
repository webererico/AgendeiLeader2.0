import 'dart:io';
import 'package:agendei/blocs/employee_bloc.dart';
import 'package:agendei/validators/employee_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EmployeeScreen extends StatefulWidget {
  final String uidEmployee;
  final DocumentSnapshot employee;
  final String uidCompany;

  EmployeeScreen({this.uidEmployee, this.employee, this.uidCompany});

  @override
  _EmployState createState() => _EmployState(uidEmployee, employee, uidCompany);
}

class _EmployState extends State<EmployeeScreen> with EmployeeValidators {
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<QuerySnapshot> snapshot;
  String uidCompany;
  String selectedGender;
  File _image;
  String _uploadedFileURL;
  final EmployeeBloc _employeeBloc;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
        'Carregando imagem...',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 3),
    ));
    final FirebaseStorage _storage =
    FirebaseStorage(storageBucket: 'gs://loja-f7ade.appspot.com');
    StorageReference storageReference =
    _storage.ref().child('companies/$uidCompany/${DateTime.now()}.png');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
        _employeeBloc.saveImg(_uploadedFileURL);
      });
    });
  }


  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uidCompany = user.uid.toString();
    return uidCompany;
  }

  @override
  void initState() {
    getUID().then((results) {
      setState(() {
        uidCompany = results;
      });
    });
    super.initState();
  }


  _EmployState(String uidEmployee, DocumentSnapshot employee, String uidCompany)
      : _employeeBloc = EmployeeBloc(
            uidEmployee: uidEmployee,
            employee: employee,
            uidCompany: uidCompany);

  Color text(){
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final _fieldStyle = TextStyle(color: text(), fontSize: 16.0);
    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
          labelText: label, labelStyle: TextStyle(color: text()));
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: StreamBuilder(
            stream: _employeeBloc.outCreated,
            initialData: false,
            builder: (context, snapshot) {
              return Text(snapshot.data
                  ? 'Editar funcionário'
                  : 'Criar novo funcionário');
            }),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _employeeBloc.outCreated,
            initialData: false,
            builder: (context, snapshot) {
              if(snapshot.data){
              return StreamBuilder<bool>(
                  stream: _employeeBloc.outLoading,
                  initialData: false,
                  builder: (context, snapshot) {
                      return IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: snapshot.data
                            ? null
                            : () {
                          return showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Apagar funcionário?'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                            'Você tem certeza que deseja  apagar esse funcionário?'),
                                        Text(
                                          'Caso exista algum calendário vinculado ao mesm, teste será apagado juntamente de todos os dados',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        'Não',
                                        style: TextStyle(
                                            color: Colors.blueAccent),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        'Sim',
                                        style: TextStyle(
                                            color: Colors.blueAccent),
                                      ),
                                      onPressed: () {
                                        _employeeBloc.deleteEmployee();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                          );
                        },
                      );

                      });
                    } else {
                      return Container();
                    }

//                  });
            }),
        ],
      ),
      floatingActionButton: StreamBuilder(
          stream: _employeeBloc.outLoading,
          initialData: false,
          builder: (context, snapshot) {
            return FloatingActionButton(
              onPressed: snapshot.data ? null : saveEmployee,
              tooltip: 'Salvar',
              backgroundColor: Color.fromARGB(255, 15, 76, 129),
              child: Icon(Icons.save),
            );
          }),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: StreamBuilder<Map>(
                stream: _employeeBloc.outData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
//                  selectedGender = snapshot.data['gender'];
                  return ListView(
                    padding: EdgeInsets.all(16.0),
                    children: <Widget>[
                      Container(
                        width: 100,
                        child: Hero(
                            tag: 'newAvatar',
                            child: snapshot.data['img'] == null
                                ? CircleAvatar(
                                  radius: 60,
                                backgroundColor: Colors.grey.withAlpha(100),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.photo_camera,
                                    color: Color.fromARGB(255, 15, 76, 129),
                                  ),
                                  onPressed: () {
                                    print('tirar foto');
                                    chooseFile();
                                  },
                                ))
                                : CircleAvatar(
                                radius: 100,
                                backgroundColor: Colors.grey.withAlpha(100),
                                backgroundImage: NetworkImage(snapshot.data['img'].toString()),
                                child: InkWell(
                                  onTap: () {
                                    chooseFile();
                                  },
                                ))),
                      ),
                      TextFormField(
                        initialValue: snapshot.data['fullName'],
                        style: _fieldStyle,
                        decoration:
                            _buildDecoration('Nome completo do funcionário'),
                        onSaved: _employeeBloc.saveFullName,
                        validator: validateFullName,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['cpf'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('CPF do funcionário'),
                        onSaved: _employeeBloc.saveCpf,
                        keyboardType: TextInputType.number,
                        validator: validateCPF,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['adress'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('Endereço do funcionário'),
                        onSaved: _employeeBloc.saveAdress,
                        validator: validateAdress,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['phone'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('Telefone do funcionário'),
                        onSaved: _employeeBloc.savePhone,
                        keyboardType: TextInputType.number,
                        validator: validatePhone,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['email'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('Email do funcionário'),
                        onSaved: _employeeBloc.saveEmail,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['function'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('Função do funcionário'),
                        onSaved: _employeeBloc.saveFuncion,
                        validator: validateFunction,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['birth'],
                        style: _fieldStyle,
                        decoration:
                            _buildDecoration('Aniversário do funcionário'),
                        onSaved: _employeeBloc.saveBirth,
                        keyboardType: TextInputType.datetime,
                        validator: validateBirth,
                      ),
                      DropdownButton(
//                        style: _fieldStyle,
                        items: <String>['Masculino', 'Feminino'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                            print(selectedGender);
                            _employeeBloc.saveGender(selectedGender == null ? snapshot.data['gender'] : selectedGender);
                          });
                        },
                        value:selectedGender ==null ? snapshot.data['gender']: selectedGender,
                        isExpanded: false,
                        hint: new Text(
                          'Genero                                                     ',
//                        style: _fieldStyle,
                          textAlign: TextAlign.center,


                        ),
                      ),
//                      TextFormField(
//                        initialValue: snapshot.data['gender'],
//                        style: _fieldStyle,
//                        decoration: _buildDecoration('Genero do funcionário'),
//                        onSaved: _employeeBloc.saveGender,
//                        validator: validateGender,
//                      ),
                    ],
                  );
                }),
          ),
          StreamBuilder(
            stream: _employeeBloc.outLoading,
            initialData: false,
              builder: (context, snapshot){
              return IgnorePointer(
                ignoring: !snapshot.data,
                child: Container(
                  color: snapshot.data ? Colors.black54 : Colors.transparent,
                ),
              );
              }
          ),
        ],
      ),
    );
  }

  void saveEmployee() async{
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      _scaffoldKey.currentState.showSnackBar(SnackBar
        (
          content: Text('Salvando funcionário...', style: TextStyle(color: Colors.white),
          ),
        duration: Duration(minutes: 1),
        backgroundColor:Colors.blueAccent,
      ),
      );
      bool success = await _employeeBloc.saveEmployee(uidCompany);
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar
        (content: Text(success ? 'Funcionário salvo com sucesso!' : 'Erro ao salvar funcionario'),
        backgroundColor:  Colors.green,
        duration: Duration(seconds: 60),
        onVisible: (){
          Navigator.of(context).pop();
        },
      )
      );
    }
  }
}
