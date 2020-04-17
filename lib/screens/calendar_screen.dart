import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<QuerySnapshot> snapshot;
  String uidCompany;
  String selectedService;
  String selectedEmployee;
  bool seg = false;
  bool ter = false;
  bool qua = false;
  bool qui = false;
  bool sex = false;
  bool sab = false;
  bool dom = false;
  bool check = false;
  TimeOfDay time = TimeOfDay.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  TimeOfDay picked;

  @override
  void initState() {
    super.initState();
    getUID().then((results) {
      setState(() {
        uidCompany = results;
      });
    });
  }

  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uidCompany = user.uid.toString();
    return uidCompany;
  }

  Future<Null> selectStartTime(BuildContext context) async {
    picked = await showTimePicker(context: context, initialTime: startTime);
    if (picked != null && picked != time) {
      setState(() {
        startTime = picked;
        print(startTime);
      });
    }
  }

  Future<Null> selectEndTime(BuildContext context) async {
    picked = await showTimePicker(context: context, initialTime: endTime);
    if (picked != null && picked != time) {
      setState(() {
        endTime = picked;
        print(endTime);
      });
    } else {
      endTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Criar novo calendário'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              Map<String, dynamic> data = {
                'name': _nameController.text,
                'uidService': selectedService,
                'uidEmployee': selectedEmployee,
                'startTime': startTime.hour.toString() +
                    ':' +
                    startTime.minute.toString(),
                'endTime':
                    endTime.hour.toString() + ':' + endTime.minute.toString(),
                'seg': seg,
                'ter': ter,
                'qua': qua,
                'qui': qui,
                'sex': sex,
                'sab': sab,
                'dom': dom,
                'check': check
              };
              saveCalendar(data);
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'Nome do calendário',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white,
                  hoverColor: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('companies')
                      .document(uidCompany)
                      .collection('services')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('Carregando');
                    } else {
                      List<DropdownMenuItem> serviceItems = [];
                      for (int i = 0; i < snapshot.data.documents.length; i++) {
                        DocumentSnapshot service = snapshot.data.documents[i];
                        serviceItems.add(DropdownMenuItem(
                          child: Text(
                            service.data['name'],
                          ),
                          value: '${service.documentID}',
                        ));
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.list,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 50.0,
                          ),
                          DropdownButton(
                            items: serviceItems,
                            onChanged: (serviceValue) {
                              setState(() {
                                selectedService = serviceValue;
                              });
                            },
                            value: selectedService,
//                            style: TextStyle(color: Colors.black),
                            isExpanded: false,
                            hint: new Text(
                              'Escolha o serviço',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                IconButton(
                    icon: Icon(
                      Icons.control_point,
                      color: Colors.white,
                    ),
                    onPressed: () {}),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('companies')
                      .document(uidCompany)
                      .collection('employees')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('Carregando');
                    } else {
                      List<DropdownMenuItem> employeeItems = [];
                      for (int i = 0; i < snapshot.data.documents.length; i++) {
                        DocumentSnapshot employee = snapshot.data.documents[i];
                        employeeItems.add(DropdownMenuItem(
                          child: Text(
                            employee.data['fullName'],
                          ),
                          value: '${employee.documentID}',
                        ));
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 50.0,
                          ),
                          DropdownButton(
                            items: employeeItems,
                            onChanged: (employeeValue) {
                              setState(() {
                                selectedEmployee = employeeValue;
                              });
                            },
                            value: selectedEmployee,
//                            style: TextStyle(color: Colors.white),
                            isExpanded: false,
                            hint: new Text(
                              '       Escolha o funcionário',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: Colors.white,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Dias da semana da Agenda',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20.0,
            ),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      'SEG',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'TER',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'QUA',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'QUI',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'SEX',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'SAB',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'DOM',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Checkbox(
//              title: Text(
//                'SEG',
//                style: TextStyle(color: Colors.white),
//              ),
                      activeColor: Colors.blueAccent,
                      onChanged: (bool resp) {
                        print('Segunda: ' + resp.toString());
                        setState(() {
                          seg = resp;
                        });
                      },
                      value: seg,
                      checkColor: Colors.white,
                    ),
                    Checkbox(
                      activeColor: Colors.blueAccent,
                      onChanged: (bool resp) {
                        print('Terca: ' + resp.toString());
                        setState(() {
                          ter = resp;
                        });
                      },
                      value: ter,
                      checkColor: Colors.white,
                    ),
                    Checkbox(
                      activeColor: Colors.blueAccent,
                      onChanged: (bool resp) {
                        print('Quarta: ' + resp.toString());
                        setState(() {
                          qua = resp;
                        });
                      },
                      value: qua,
                      checkColor: Colors.white,
                    ),
                    Checkbox(
                      activeColor: Colors.blueAccent,
                      onChanged: (bool resp) {
                        print('Quinta: ' + resp.toString());
                        setState(() {
                          qui = resp;
                        });
                      },
                      value: qui,
                      checkColor: Colors.white,
                    ),
                    Checkbox(
                      activeColor: Colors.blueAccent,
                      onChanged: (bool resp) {
                        print('Sexta: ' + resp.toString());
                        setState(() {
                          sex = resp;
                        });
                      },
                      value: sex,
                      checkColor: Colors.white,
                    ),
                    Checkbox(
                      activeColor: Colors.blueAccent,
                      onChanged: (bool resp) {
                        print('Sabado: ' + resp.toString());
                        setState(() {
                          sab = resp;
                        });
                      },
                      value: sab,
                      checkColor: Colors.white,
                    ),
                    Checkbox(
                      activeColor: Colors.blueAccent,
                      onChanged: (bool resp) {
                        print('Domingo: ' + resp.toString());
                        setState(() {
                          dom = resp;
                        });
                      },
                      value: dom,
                      checkColor: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 45),
                Divider(
                  color: Colors.white,
                ),
                Text(
                  'Horário de Funcionamento',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      time == startTime
                          ? 'INÍCIO'
                          : (startTime.hour.toString() +
                              ':' +
                              startTime.minute.toString()),
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.timer,
                          color: Colors.white,
                        ),
                        onPressed: () {
//                      return Data();
                          selectStartTime(context);
                        }),
                    Text(
                      time == endTime
                          ? 'FIM'
                          : (endTime.hour.toString() +
                              ':' +
                              endTime.minute.toString()),
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.timer,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        selectEndTime(context);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  color: Colors.white,
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Permitir mais de um agendamento no mesmo horário?',
                      style: TextStyle(fontSize: 20, color: Colors.white),),
                    ),
                    Checkbox(
                      value: check,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setState(() {
                          check = value;
                        });
                      },
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void saveCalendar(Map<String, dynamic> data) async {
    if (_formKey.currentState.validate()) {
      print('salvando calendário');

      _formKey.currentState.save();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Criando novo calendário da empresa...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        duration: Duration(minutes: 1),
      ));
      await Firestore.instance
          .collection('companies')
          .document(uidCompany)
          .collection('calendars')
          .add(data);
      print('salvou');
//      bool success = await _profileBloc.saveCompany(usera);
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
//          success ? 'Dados atualizados com sucesso!' : 'Erro ao salvar serviço',
          'passou',
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
