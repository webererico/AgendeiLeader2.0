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
  bool name = true;
  bool service = false;
  bool employee = false;
  bool day = false;
  bool timers = false;
  DateTime time;
  DateTime startTime;
  DateTime endTime;
  TimeOfDay picked;
  double _kPickerSheetHeight = 300.0;
  Color text (){
    return Colors.black;
  }

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

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                  textColor: Colors.blueAccent,
                  child: Text(
                    'OK',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          ),
          Container(
            width: 140,
            height: 140,
            child: picker,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Criar novo calendário'),
        actions: <Widget>[
          endTime != null ? IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              Map<String, dynamic> data = {
                'name': _nameController.text,
                'uidService': selectedService,
                'uidEmployee': selectedEmployee,
                'startTime': Timestamp.fromDate(startTime),
                'endTime': Timestamp.fromDate(endTime),
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
          ): IconButton(
              icon: Icon(Icons.save),
              onPressed:  null,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: text()),
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'Nome do calendário',
                  labelStyle: TextStyle(color: text()),
                  fillColor: text(),
                  hoverColor: text()),
              onChanged: (value){
                _nameController.text = value;
                name = true;
              },
            ),
            Visibility(
              visible: name == true ? true :false,
              child: Row(
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
                              color: text(),
                            ),
                            SizedBox(
                              width: 50.0,
                            ),
                            DropdownButton(
                              items: serviceItems,
                              onChanged: (serviceValue) {
                                setState(() {
                                  selectedService = serviceValue;
                                  service = true;
                                });
                              },
                              value: selectedService,
//                            style: TextStyle(color: Colors.black),
                              isExpanded: false,
                              hint: new Text(
                                'Escolha o serviço',
                                style: TextStyle(color: text()),
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
                        color: text(),
                      ),
                      onPressed: () {}),
                ],
              ),
            ),
            Visibility(
              visible: service == true? true : false,
              child: Row(
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
                              color: text(),
                            ),
                            SizedBox(
                              width: 50.0,
                            ),
                            DropdownButton(
                              items: employeeItems,
                              onChanged: (employeeValue) {
                                setState(() {
                                  selectedEmployee = employeeValue;
                                  employee= true;
                                });
                              },
                              value: selectedEmployee,
//                            style: TextStyle(color: text()),
                              isExpanded: false,
                              hint: new Text(
                                '       Escolha o funcionário',
                                style: TextStyle(color: text()),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: text(),
            ),
            SizedBox(
              height: 10.0,
            ),
            Visibility(
              visible: employee == true ? true : false,
              child: Text(
                'Dias da semana da Agenda',
                style: TextStyle(color: text(), fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Visibility(
              visible: employee == true? true : false,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'SEG',
                        style: TextStyle(color: text()),
                      ),
                      Text(
                        'TER',
                        style: TextStyle(color: text()),
                      ),
                      Text(
                        'QUA',
                        style: TextStyle(color: text()),
                      ),
                      Text(
                        'QUI',
                        style: TextStyle(color: text()),
                      ),
                      Text(
                        'SEX',
                        style: TextStyle(color: text()),
                      ),
                      Text(
                        'SAB',
                        style: TextStyle(color: text()),
                      ),
                      Text(
                        'DOM',
                        style: TextStyle(color: text()),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        onChanged: (bool resp) {
                          print('Segunda: ' + resp.toString());
                          setState(() {
                            seg = resp;
                            day = true;
                          });
                        },
                        value: seg,
                        checkColor: text(),
                      ),
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        onChanged: (bool resp) {
                          print('Terca: ' + resp.toString());
                          setState(() {
                            ter = resp;
                            day = true;
                          });
                        },
                        value: ter,
                        checkColor: text(),
                      ),
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        onChanged: (bool resp) {
                          print('Quarta: ' + resp.toString());
                          setState(() {
                            qua = resp;
                            day = true;
                          });
                        },
                        value: qua,
                        checkColor: text(),
                      ),
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        onChanged: (bool resp) {
                          print('Quinta: ' + resp.toString());
                          setState(() {
                            qui = resp;
                            day = true;
                          });
                        },
                        value: qui,
                        checkColor: text(),
                      ),
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        onChanged: (bool resp) {
                          print('Sexta: ' + resp.toString());
                          setState(() {
                            sex = resp;
                            day = true;
                          });
                        },
                        value: sex,
                        checkColor: text(),
                      ),
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        onChanged: (bool resp) {
                          print('Sabado: ' + resp.toString());
                          setState(() {
                            sab = resp;
                            day = true;
                          });
                        },
                        value: sab,
                        checkColor: text(),
                      ),
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        onChanged: (bool resp) {
                          print('Domingo: ' + resp.toString());
                          setState(() {
                            dom = resp;
                            day = true;
                          });
                        },
                        value: dom,
                        checkColor: text(),
                      ),
                    ],
                  ),
                  SizedBox(height: 45),
                  Visibility(
                    visible:  day == true? true : false,
                    child: Divider(
                      color: text(),
                    ),
                  ),
                  Visibility(
                    visible: day == true ? true : false,
                    child: Text(
                      'Horário de Funcionamento',
                      style: TextStyle(color: text(), fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Visibility(
                    visible: day == true? true : false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          time == startTime
                              ? 'INÍCIO'
                              : (startTime.hour.toString() +
                                  ':' +
                                  startTime.minute.toString()),
                          style: TextStyle(color: text()),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.access_time,
                              color: text(),
                            ),
                            onPressed: () {
                              showCupertinoModalPopup<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return _buildBottomPicker(
                                    CupertinoDatePicker(
                                      initialDateTime: DateTime(2020, 4, 22, 12, 00),
                                      minuteInterval: 30,
                                      use24hFormat: true,
                                      mode: CupertinoDatePickerMode.time,
                                      onDateTimeChanged: (value) {
                                        setState(() {
                                          startTime = value;
                                        });
                                      },
                                    ),
                                  );
                                },
                              );
                            }),
                        Text(
                          time == endTime
                              ? 'FIM'
                              : (endTime.hour.toString() +
                                  ':' +
                                  endTime.minute.toString()),
                          style: TextStyle(color: text()),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.watch_later,
                            color: text(),
                          ),
                          onPressed: () {
                            showCupertinoModalPopup<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return _buildBottomPicker(
                                  CupertinoDatePicker(
                                    initialDateTime: DateTime(2020, 4, 22, 12, 00),
                                    minuteInterval: 30,
                                    use24hFormat: true,
                                    mode: CupertinoDatePickerMode.time,
                                    onDateTimeChanged: (value) {
                                      setState(() {
                                        endTime = value;
                                        timers = true;
                                      });
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Divider(
                    color: text(),
                  ),
                  Visibility(
                    visible: timers == true ? true : false,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Permitir mais de um agendamento no mesmo horário?',
                            style: TextStyle(fontSize: 20, color: text()),
                          ),
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
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveCalendar(Map<String, dynamic> data) async {

    if (_formKey.currentState.validate()) {
      print('salvando calendário');
      if(startTime.isBefore(endTime)){
        _formKey.currentState.save();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Criando novo calendário da empresa...',
            style: TextStyle(color: Colors.black),
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
      }else{
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'O horário inicial precisa ser antes do final',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      }

    }
  }
}
