import 'dart:async';
import 'package:agendei/tabs/configs_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BugReportScreen extends StatefulWidget {
  @override
  _BugReportScreenState createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _subjectController = TextEditingController();
  final _textController = TextEditingController();
  bool check = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Reportar bug'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Assunto",
                    labelStyle: TextStyle(color: Colors.white),
                    icon: Icon(Icons.subject)),
                validator: (text) {
                  if (text.isEmpty) {
                    return 'Assunto inválido';
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText:
                    "Descreva o problema ou a situação em que ocorreu.",
                    hintMaxLines: 3,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  validator: (text) {
                    if (text.isEmpty) {
                      return "Insira uma explicação do erro";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Row(
                children: [
                  Flexible(
                      child: Text(
                        'Deseja ser notificado sobre a solução deste problema?',
                      )),
                  Checkbox(
                      value: check,
                      onChanged: (value) {
                        setState(() {
                          check = value;
                        });
                      }),
                ],
              ),
              FloatingActionButton.extended(
                icon: Icon(Icons.bug_report),
                label: Text('Reportar'),
                onPressed: () {
                  saveReport();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void saveReport() async {
    DateTime now = DateTime.now();
    Timestamp created_at = Timestamp.fromDate(now);
    if (_formKey.currentState.validate()) {
      final FirebaseUser company = await FirebaseAuth.instance.currentUser();
      Map<String, dynamic> bugReport = {
        'uidCompany': company.uid,
        'name': company.displayName,
        'email': company.email,
        'subject': _subjectController.text.toString(),
        'text:': _textController.text.toString(),
        'notificar': check,
        'created_at': created_at
      };

      _scaffoldKey.currentState.showSnackBar(SnackBar(

        content: check == true
            ? Text(
            'Problema reportado. Você será contatado por e-mail sobre a solução deste problema.')
            : Text(
            'Reporte realizado com sucesso. Nossa equipe solucionará este problema'),
        backgroundColor: Colors.orange,
      ));
      Firestore.instance
          .collection('companyReports')
          .document(now.toIso8601String())
          .setData(bugReport);
      Timer(
          Duration(seconds: 4),
              () => Navigator.of(context).pop());
    }
  }
}
