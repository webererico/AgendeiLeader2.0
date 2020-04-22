import 'package:agendei/blocs/service_bloc.dart';
import 'package:agendei/validators/service_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceScreen extends StatefulWidget {
  final String uidService;
  final DocumentSnapshot service;
  final String uidCompany;

  ServiceScreen({this.uidService, this.service, this.uidCompany});

  @override
  _ServiceScreenState createState() =>
      _ServiceScreenState(uidService, service, uidCompany);
}

class _ServiceScreenState extends State<ServiceScreen> with ServiceValidators {
  FirebaseAuth auth = FirebaseAuth.instance;
  String uidCompany = '';
  Future<QuerySnapshot> snapshot;

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

  final ServiceBloc _serviceBloc;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _ServiceScreenState(
      String uidService, DocumentSnapshot service, String uidCompany)
      : _serviceBloc = ServiceBloc(
            uidService: uidService, service: service, uidCompany: uidCompany);

  @override
  Widget build(BuildContext context) {
    final _fieldStyle = TextStyle(
      color: Colors.white,
      fontSize: 20.0,
    );
    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
          labelText: label, labelStyle: TextStyle(color: Colors.white, fontSize: 20.0));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0.0,
        title: StreamBuilder(
          stream: _serviceBloc.outCreated,
          initialData: false,
          builder: (context, snapshot) {
            return Text(
                snapshot.data ? 'Editar Serviço' : 'Criar novo serviço');
          },
        ),
        actions: <Widget>[
          StreamBuilder<bool>(
              stream: _serviceBloc.outCreated,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return StreamBuilder<bool>(
                      stream: _serviceBloc.outLoading,
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
                                    // user must tap button!
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Apagar serviço?'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(
                                                  'Você tem certeza que deseja apagar esse serviço?'),
                                              Text(
                                                'Caso exista algum calendário vinculado a esse serviço, o mesmo será apagado junto com seus agendamentos.',
                                                style: TextStyle(
                                                    color: Colors.red),
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
                                              _serviceBloc.deleteService();
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
//                        Navigator.of(context).pop();
                                },
                        );
                      });
                } else {
                  return Container();
                }
              }),
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
          stream: _serviceBloc.outLoading,
          initialData: false,
          builder: (context, snapshot) {
            return FloatingActionButton(
              onPressed: snapshot.data ? null : saveService,
              tooltip: 'Salvar',
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.save),
            );
          }),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: StreamBuilder<Map>(
                stream: _serviceBloc.outData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  return ListView(
                    padding: EdgeInsets.all(16.0),
                    children: <Widget>[
//                  Text('imagem',
//                      style: TextStyle(
//                        color: Colors.grey,
//                        fontSize: 12
//                      ),
//                  ),
//                  ImageWidget(
//                    context: context,
//                    initialValue: snapshot.data['img'],
//                    onSaved: (l){
//
//                    },
//                    validator: (l){},
//                  ),
                      TextFormField(
                        initialValue: snapshot.data['name'],
                        style: _fieldStyle,
                        decoration: _buildDecoration('Nome do serviço'),
                        onSaved: _serviceBloc.saveName,
                        validator: validateName,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['description'],
                        style: _fieldStyle,
                        maxLines: 3,
                        decoration: _buildDecoration('Descrição'),
                        onSaved: _serviceBloc.saveDescription,
                        validator: validateDescription,
                      ),
                      TextFormField(
                        initialValue: snapshot.data['price'],
                        style: _fieldStyle,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: _buildDecoration('Valor (R\$)'),
                        onSaved: _serviceBloc.savePrice,
                        validator: validatePrice,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text('Tempo médio de duração (minutos)',style: TextStyle(color: Colors.white,
                              fontSize: 20.0,),),
                          ),
                          DropdownButton<String>(
                            value: snapshot.data['duration'].toString(),
                            icon: Icon(Icons.timelapse, color: Colors.white,),
                            iconSize: 30,
                            elevation: 16,
                            style: TextStyle(color: Colors.blueAccent),
//                            underline: Container(
//                              height: 2,
//                              color: Colors.deepPurpleAccent,
//                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                _serviceBloc.saveDuration(int.parse(newValue));
                              });
                            },
                            items: <String>['1', '5', '6', '10','12', '15', '20','30']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: 22.0),),
                              );
                            }).toList(),
                          )
                        ],
                      ),
//                      TextFormField(
//                        initialValue: snapshot.data['duration'],
//                        style: _fieldStyle,
//                        keyboardType:
//                            TextInputType.numberWithOptions(decimal: true),
//                        decoration: _buildDecoration(
//                            'Tempo médio de duração (minutos)'),
//                        onSaved: _serviceBloc.saveDuration,
//                        validator: validateDuration,
//                      ),
                    ],
                  );
                }),
          ),
          StreamBuilder<bool>(
              stream: _serviceBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: !snapshot.data,
                  child: Container(
//                    child: CircularProgressIndicator(),
                    color: snapshot.data ? Colors.black54 : Colors.transparent,
                  ),
                );
              }),
        ],
      ),
    );
  }

  void saveService() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Salvando serviço...',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(minutes: 1),
        backgroundColor: Colors.blueAccent,
      ));
      bool success = await _serviceBloc.saveService(uidCompany);
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          success ? 'Serviço salvo com sucesso!' : 'Erro ao salvar serviço',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 60),
        onVisible: () {
          Navigator.of(context).pop(context);
        },
      ));
    }
  }
}
