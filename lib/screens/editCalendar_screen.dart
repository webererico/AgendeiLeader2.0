import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditCalendarScreen extends StatefulWidget {
  final String uidCompany;
  final String uidCalendar;

  EditCalendarScreen({this.uidCompany, this.uidCalendar, Key key})
      : super(key: key);

  @override
  _EditCalendarScreenState createState() =>
      _EditCalendarScreenState(uidCalendar, uidCompany);
}

class _EditCalendarScreenState extends State<EditCalendarScreen> {
  String uidCompany;
  String uidCalendar;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();

//  EditCalendarScreen(uidCompany, uidCalendar);
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<QuerySnapshot> snapshot;
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
  bool changed = false;
  DateTime time = DateTime.now();
  DateTime startTime;
  DateTime endTime;
  DateTime picked;
  DateTime lastEndTime;
  DateTime lastStartTime;

  @override
  void initState() {
    getData();
    super.initState();
  }

  _EditCalendarScreenState(String uidCalendar, String uidCompany) {
    uidCompany = this.uidCompany;
    uidCalendar = this.uidCalendar;
  }

  void getData() async {
    DocumentSnapshot calendar = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .document(widget.uidCalendar)
        .get();
    Timestamp endTime = calendar.data['endTime'];
    Timestamp startTime = calendar.data['startTime'];
    setState(() {
      nameController.text = calendar.data['name'];
      selectedEmployee = calendar.data['uidEmployee'];
      selectedService = calendar.data['uidService'];
      seg = calendar.data['seg'];
      ter = calendar.data['ter'];
      qua = calendar.data['qua'];
      qui = calendar.data['qui'];
      sex = calendar.data['sex'];
      sab = calendar.data['sab'];
      dom = calendar.data['dom'];
      check = calendar.data['check'];
      lastEndTime = endTime.toDate();
      lastStartTime = startTime.toDate();
    });
  }

  double _kPickerSheetHeight = 300.0;

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Editar calendário'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              deleteCalendar();
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
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: 'Nome do calendário',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white,
                  hoverColor: Colors.white),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('companies')
                  .document(widget.uidCompany)
                  .collection('services')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Carregando');
                } else {
                  List<DropdownMenuItem> serviceItems = [];
                  print(snapshot.data.documents.length);
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
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('companies')
                  .document(widget.uidCompany)
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
                        isExpanded: false,
                        hint: new Text(
                          'Escolha o funcionário',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }
              },
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
                    lastStartTime != null ? Text('${lastStartTime.hour}:${lastStartTime.minute}',
                        style: TextStyle(color: Colors.white)): Text('INÍCIO'),
                    IconButton(
                        icon: Icon(
                          Icons.access_time,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return _buildBottomPicker(
                                CupertinoDatePicker(
                                  initialDateTime:
                                      DateTime(2020, 4, 22, lastStartTime.hour, lastStartTime.minute),
                                  minuteInterval: 30,
                                  use24hFormat: true,
                                  mode: CupertinoDatePickerMode.time,
                                  onDateTimeChanged: (value) {
                                    setState(() {
                                      startTime = value;
                                      lastStartTime  = value;
                                      changed = true;
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        }),
                   lastEndTime != null ? Text('${lastEndTime.hour}:${lastEndTime.minute}',
                        style: TextStyle(color: Colors.white)): Text('FIM'),
                    IconButton(
                      icon: Icon(
                        Icons.timer,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showCupertinoModalPopup<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return _buildBottomPicker(
                              CupertinoDatePicker(
                                initialDateTime:
                                DateTime(2020, 4, 22, lastEndTime.hour, lastEndTime.minute),
                                minuteInterval: 30,
                                use24hFormat: true,
                                mode: CupertinoDatePickerMode.time,
                                onDateTimeChanged: (value) {
                                  setState(() {
                                    endTime = value;
                                    lastEndTime  = value;
                                    changed = true;
                                  });
                                },
                              ),
                            );
                          },
                        );                      },
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
                        style: TextStyle(fontSize: 20, color: Colors.white),
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
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Map<String, dynamic> data = {
            'name': nameController.text,
            'uidService': selectedService,
            'uidEmployee': selectedEmployee,
            'startTime': Timestamp.fromDate(lastStartTime),
            'endTime': Timestamp.fromDate(lastEndTime),
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
        label: Text('Atualizar'),
        icon: Icon(Icons.check),
      ),
    );
  }

  void saveCalendar(Map<String, dynamic> data) async {
    if (_formKey.currentState.validate()) {
      if(lastStartTime.isBefore(lastEndTime)){
        await Firestore.instance
            .collection('companies')
            .document(widget.uidCompany)
            .collection('calendars')
            .document(widget.uidCalendar)
            .updateData(data);
        print('salvou');
        print('salvando calendário');
        _formKey.currentState.save();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Atualizando calendário...',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: Duration(minutes: 1),
          onVisible: () {
          Navigator.of(context).pop();
          },
        ));
        await Firestore.instance
            .collection('companies')
            .document(widget.uidCompany)
            .collection('calendars')
            .document(widget.uidCalendar)
            .updateData(data);
        print('salvou');
        _scaffoldKey.currentState.removeCurrentSnackBar(
        );
      }else{
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'O horário de início deve ser anterior ao de final...',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(minutes: 1),
        ));
      }

    }
  }

  void deleteCalendar() async {
    Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .document(widget.uidCalendar)
        .delete();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        'Apagando calendário permanentemente',
        style: TextStyle(color: Colors.white),
      ),
      elevation: 2.0,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.orange,
    ));
    Navigator.of(context).pop(context);
  }
}
