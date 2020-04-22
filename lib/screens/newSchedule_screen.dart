import 'package:agendei/screens/newClient_screen.dart';
import 'package:agendei/tabs/calendars_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewScheduleScreen extends StatefulWidget {
  @override
  _NewScheduleScreenState createState() => _NewScheduleScreenState();
}

class _NewScheduleScreenState extends State<NewScheduleScreen> {
  final _scaffold = GlobalKey<ScaffoldState>();
  String uidCompany;
  String selectedService;
  String selectedClient;
  DateTime selectedDate;
  DateTime selectedTime;
  List<DropdownMenuItem> employeeItems = [];
  List<DropdownMenuItem> clientsItems = [];
  DateTime startHour;
  DateTime endHour;
  bool time = false;
  String selectedEmployee;
  int timeDurationService = 0;
  String selectedCalendar;

  getCompany() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot querySnapshotClients = await Firestore.instance
        .collection('companies')
        .document(user.uid)
        .collection('clientes')
        .getDocuments();
    for (int index = 0;
        index < querySnapshotClients.documents.length;
        index++) {
      DocumentSnapshot client = await Firestore.instance
          .collection('users')
          .document(querySnapshotClients.documents[index].documentID)
          .get();
      setState(() {
        clientsItems.add(DropdownMenuItem(
          child: Text(client.data['name']),
          value: '${client.documentID}',
        ));
      });
    }
    print('empresa:' + user.uid.toString());
    return user.uid.toString();
  }

  void getCalendars() async {
    final QuerySnapshot query = await Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('calendars')
        .where('uidService', isEqualTo: selectedService)
        .getDocuments();

    List<DocumentSnapshot> calendarItems = [];
    for (int i = 0; i < query.documents.length; i++) {
      calendarItems.add(query.documents[i]);
    }
//    print('calendarios com o servico encontrados: ' +
//        calendarItems.length.toString());
    getEmployee(calendarItems);
  }

  void getEmployee(List<DocumentSnapshot> calendar) async {
    for (int i = 0; i < calendar.length; i++) {
      print(calendar[i].data['name']);
      final DocumentSnapshot employee = await Firestore.instance
          .collection('companies')
          .document(uidCompany)
          .collection('employees')
          .document(calendar[i].data['uidEmployee'])
          .get();
      print('funcionario: ' + employee.data['fullName']);
      if (!employeeItems.contains(employee.documentID)) {
        setState(() {
          employeeItems.add(DropdownMenuItem(
            child: Text(employee.data['fullName']),
            value: '${employee.documentID}',
          ));
        });
      }
    }
    if (employeeItems.length == 1) {
      setState(() {
        selectedEmployee = employeeItems[0].value;
        findTimeDuration(selectedService);
      });
    }
  }

  showDataPicker() async {
    final DateTime data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    setState(() {
      selectedTime = null;
      selectedDate = data;
      print(selectedDate);
    });
    if (selectedDate != null) {
      getOrderCalendar(selectedService, selectedEmployee);
    }
  }

  void getOrderCalendar(String uidService, String uidEmployee) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('calendars')
        .where(
          'uidService',
          isEqualTo: uidService,
        )
        .where('uidEmployee', isEqualTo: uidEmployee)
        .limit(1)
        .getDocuments();
    Timestamp _start = querySnapshot.documents[0].data['startTime'];
    Timestamp _end = querySnapshot.documents[0].data['endTime'];
    startHour = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, _start.toDate().hour, _start.toDate().minute);
    endHour = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        _end.toDate().hour, _end.toDate().minute);
    setState(() {
      selectedCalendar = querySnapshot.documents[0].documentID;
    });
  }
  double _kPickerSheetHeight = 300.0;

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
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
                  }
              ),
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

  findTimeDuration(String selectedService) async {
    final DocumentSnapshot service = await Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('services')
        .document(selectedService)
        .get();
    setState(() {
      timeDurationService = service.data['duration'];
    });
    print('tempo Duracao servico: ' + timeDurationService.toString());
  }
  void verifyOrderExist() async{
    QuerySnapshot querySnapshot = await Firestore.instance.collection('companies').document(uidCompany).collection('calendars').document(selectedCalendar).collection('orders').where('dateTime', isEqualTo: selectedDate).getDocuments();
    if(querySnapshot.documents.length > 0){
      _showSnack(context, 'Este horário não está disponível, por favor, solicite outro', Colors.red);
    }else{
      verifyDate();
//      saveOrder();
    }
  }
  void verifyDate() async{
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection('companies').document(uidCompany).collection('caledars').document(selectedCalendar).get();
    if(documentSnapshot.exists){
      Timestamp calendarStart = documentSnapshot.data['startTime'];
      Timestamp calendarEnd = documentSnapshot.data['endTime'];
      DateTime start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, calendarStart.toDate().hour, calendarStart.toDate().minute );
      DateTime end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,calendarEnd.toDate().hour, calendarEnd.toDate().minute );
      if(selectedDate.isAfter(start) && selectedDate.isBefore(end)){
        saveOrder();
      }else{
        _scaffold.currentState.removeCurrentSnackBar();
        _showSnack(context, 'Horário inválido. Informe um horário entre ${start.hour}:${start.minute} e ${end.hour}:${end.minute}.', Colors.orange);
      }
    }
  }

  void saveOrder() async {
    _showSnack(context, 'Verificando horários disponíveis...', Colors.orange);
    Timestamp createdAt = Timestamp.fromDate(DateTime.now());
    final Map<String, dynamic> scheduleData = {
      'uidClient': selectedClient,
      'dateTime': Timestamp.fromDate(selectedDate).toDate(),
      'uidService': selectedService,
      'uidEmployee': selectedEmployee,
      'uidCalendar': selectedCalendar,
      'statusPayment': 'não pago',
      'statusSchedule': 'agendado',
      'createdAt': createdAt
    };
    final Map<String, dynamic> scheduleUserData = {
      'uidCompany': uidCompany,
      'dateTime': Timestamp.fromDate(selectedDate).toDate(),
      'uidService': selectedService,
      'uidEmployee': selectedEmployee,
      'uidCalendar': selectedCalendar,
      'statusPayment': 'não pago',
      'statusSchedule': 'agendado',
      'createdAt': createdAt
    };
    print(scheduleUserData);
    final QuerySnapshot calendar = await Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('calendars')
        .where('uidEmployee', isEqualTo: selectedEmployee)
        .where('uidService', isEqualTo: selectedService)
        .getDocuments();
    for (int i = 0; i < calendar.documents.length; i++) {
      print('salvando');
      final DocumentReference documentReference = await Firestore.instance
          .collection('companies')
          .document(uidCompany)
          .collection('calendars')
          .document(calendar.documents[i].documentID)
          .collection('orders')
          .add(scheduleData);
      await Firestore.instance
          .collection('users')
          .document(selectedClient)
          .collection('orders')
          .document(documentReference.documentID)
          .setData(scheduleUserData);
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        _scaffold.currentState.removeCurrentSnackBar();
        return AlertDialog(
          title: Text('Agendamento realizado com sucesso!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Seu horário foi reservado com sucesso. Caso seja necessário remarcar ou cancelar, é possível fazer em até 3 dias úteis antes da data marcada por meio do menu agendamentos.'),
                Padding(padding: EdgeInsets.only(top: 20)),
                Text('Agradecemos por utilizar o Agendei :D'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CalendarTab()));
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnack(BuildContext context, String text, MaterialColor cor) {
    _scaffold.currentState.showSnackBar(
      SnackBar(
        content: Container(height: 80.0, child: Text(text, style: TextStyle(fontSize: 14),)),
        action: text == 'Este horário não está disponível, por favor, solicite outro'? SnackBarAction(
            label: 'sugestão de horario',
            textColor: Colors.white,
            onPressed: (){
              print('sugestao');
            }
        ) : SnackBarAction(
          onPressed: (){},
          label: ' ',
        ),
        backgroundColor: cor,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCompany().then((result) {
      setState(() {
        uidCompany = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Novo agendamento'),
        actions: [
          IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => NewClientScreen()));
              })
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if(selectedTime != null){
            verifyOrderExist();
          }else{
            _showSnack(context, 'Selecione um horario para agendamento', Colors.red);
          }
        },
        label: Text('Agendar'),
        backgroundColor: Colors.blueAccent,
        icon: Icon(Icons.search),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Cliente:',
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                  Icon(
                    Icons.list,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  DropdownButton(
                    items: clientsItems,
                    onChanged: (clientValue) {
                      setState(() {
                        print('cliente selecionado: ' + selectedClient);
                        selectedClient = clientValue.toString();
                      });
                    },
                    value: selectedClient,
                    isExpanded: false,
                    hint: new Text(
                      'Escolha o cliente',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Serviços:',
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
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
                            child: Text(service.data['name']),
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
                              width: 10.0,
                            ),
                            DropdownButton(
                              items: serviceItems,
                              onChanged: (serviceValue) {
//                              agendar = false;
//                              lastMinutes = 0;
//                              lastHours = 0;
                                employeeItems.clear();
                                selectedEmployee = null;
//                              selectedDate = null;
//                              selectedTime = null;
                                setState(() {
                                  print('servico selecionado: ' + serviceValue);
                                  selectedService = serviceValue;
                                });
                                getCalendars();
                              },
                              value: selectedService,
                              isExpanded: false,
                              hint: new Text(
                                'Escolha o serviço',
                                style: TextStyle(color: Colors.black),
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
              height: 40,
            ),
            Visibility(
              visible: selectedService == null ? false : true,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Funcionário:',
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.list,
                          size: 25.0,
                          color: Colors.white,
                        ),

                        DropdownButton(
                          items: employeeItems,
                          onChanged: (employeeValue) {
                            setState(() {
                              selectedEmployee = employeeValue;
                               timeDurationService  = 0;
                               findTimeDuration(selectedService);
                            });

                          },
                          value: selectedEmployee,
                          isExpanded: false,
                          hint: new Text(
                            'Escolha o funcionário',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Visibility(
              visible: selectedEmployee == null ? false : true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Escolha a data:',
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  selectedDate == null
                      ? Text('')
                      : Text(
                          selectedDate.day.toString() +
                              '/' +
                              selectedDate.month.toString() +
                              '/' +
                              selectedDate.year.toString(),
                          style: TextStyle(fontSize: 20.0),
                        ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      time = false;
                      showDataPicker();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Visibility(
              visible: selectedDate != null ? true : false,
              child: Row(
                children: <Widget>[
                  Text('Escolha o horário:',
                      style: TextStyle(color: Colors.black, fontSize: 22)),
                  SizedBox(
                    width: 10,
                  ),
                  selectedTime == null
                      ? Text('')
                      : Text(
                    selectedTime.hour.toString() +
                        ':' +
                        selectedTime.minute.toString(),
                    style: TextStyle(fontSize: 20.0),
                  ),
                  IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
//                            int minute =
                            return _buildBottomPicker(
                              CupertinoDatePicker(
                                minuteInterval: timeDurationService != 0 ? timeDurationService : 5,
                                use24hFormat: true,
                                mode: CupertinoDatePickerMode.time,
                                initialDateTime: DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    startHour.hour,
                                    startHour.minute),
                                maximumDate: endHour,
                                minimumDate: startHour,
                                onDateTimeChanged: (value) {
                                  setState(() {
                                    selectedDate = value;
                                    selectedTime = value;
                                    time = true;
                                  });
                                  print(time);
                                  print('hora selecionada:' +
                                      selectedTime.toIso8601String());
                                },
                              ),
                            );
                          },
                        );
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
