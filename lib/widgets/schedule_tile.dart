import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ScheduleTile extends StatefulWidget {
  final String uidCalendar;
  final DocumentSnapshot order;

  ScheduleTile({this.uidCalendar, this.order, Key key}) : super(key: key);

  @override
  _ScheduleTileState createState() => _ScheduleTileState();
}

class _ScheduleTileState extends State<ScheduleTile> {
  String statusSchedule;
  String uidCompany;
  var start;
  var finish;

  getUid() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  @override
  void initState() {
    super.initState();
    getUid().then((result) {
      setState(() {
        uidCompany = result;
      });
    });
    setState(() {
      statusSchedule = widget.order.data['statusSchedule'];
    });
  }

  startService(String status) async {
    start = Timestamp.fromDate(DateTime.now());
    final Map<String, dynamic> data = {
      'statusSchedule': status,
      'startService': start
    };
    Firestore.instance
        .collection('users')
        .document(widget.order.data['uidClient'])
        .collection('orders')
        .document(widget.order.documentID)
        .updateData(data);
    print('user-> order -> updated');
    print('uidcalendar: ' + widget.uidCalendar);
    print('uid da order: ' + widget.order.documentID);
    Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('calendars')
        .document(widget.uidCalendar)
        .collection('orders')
        .document(widget.order.documentID)
        .updateData(data);
    setState(() {
      statusSchedule = status;
    });
  }

  finishService(String status, DateTime finish, int duration) async {

    final Map<String, dynamic> data = {
//      'createdAt':
      'statusSchedule': status,
      'finishService': Timestamp.fromDate(finish),
      'duration': duration,
      'evalueationService': null,
      'evalueationEmployee': null
    };
    DocumentSnapshot documentSnapshotUser = await Firestore.instance
        .collection('users')
        .document(widget.order.data['uidClient'])
        .collection('orders')
        .document(widget.order.documentID)
        .get();
//    documentSnapshotUser.data.update('statusSchedule', (value) => status);
//    documentSnapshotUser.data['finishService'] = Timestamp.fromDate(finish);
//    documentSnapshotUser.data['duration'] = duration;
//    Firestore.instance
//        .collection('users')
//        .document(widget.order.data['uidClient'])
//        .collection('orders')
//        .document(widget.order.documentID)
//        .delete();
    Firestore.instance
        .collection('users')
        .document(widget.order.data['uidClient'])
        .collection('orders')
        .document(documentSnapshotUser.documentID)
        .updateData(data);

    print('salvou no usuario... servico finalizado');

    DocumentSnapshot documentSnapshotCompany = await Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('calendars')
        .document(widget.uidCalendar)
        .collection('orders')
        .document(widget.order.documentID)
        .get();

    Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('calendars')
        .document(widget.uidCalendar)
        .collection('orders')
        .document(widget.order.documentID)
        .delete();
    Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('services')
        .document(widget.order.data['uidService'])
        .collection('history')
        .document(documentSnapshotCompany.documentID)
        .setData(documentSnapshotCompany.data);
    Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('services')
        .document(widget.order.data['uidService'])
        .collection('history')
        .document(documentSnapshotCompany.documentID)
        .updateData(data);

    print('salvou no historico do servico da empresa');

    setState(() {
      statusSchedule = status;
    });
    setState(() {
      statusSchedule = status;
    });
  }

  getStart() async {
    DocumentSnapshot documentSnapshot = await Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('calendars')
        .document(widget.uidCalendar)
        .collection('orders')
        .document(widget.order.documentID)
        .get();
    if(documentSnapshot.data['startService']!= null){
      setState(() {
        start = DateTime.parse(documentSnapshot.data['startService']);
        print('start: '+start.toString());
      });
    }

  }

  Future<void> _askedToLead() async {
    DocumentSnapshot documentSnapshot = await Firestore.instance
        .collection('companies')
        .document(uidCompany)
        .collection('calendars')
        .document(widget.uidCalendar)
        .collection('orders')
        .document(widget.order.documentID)
        .get();
    if(documentSnapshot.data['startService']!= null){
        Timestamp time = documentSnapshot.data['startService'];
        start = time.toDate();
        print('start: '+start.toString());
    }
    var finish = new DateTime.now();
    final duration = finish.difference(start);
    print('duracao do servico: ' + duration.toString());
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(10.0),
            title: const Text(
              'Serviço Finalizado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              Text('Duração: ' + duration.inMinutes.toString() + ' minutos'),
              SizedBox(
                height: 10,
              ),
              Text('Status pagamento: ' + widget.order.data['statusPayment']),
              SizedBox(
                height: 10,
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: FlatButton.icon(
                  icon: Icon(
                    Icons.attach_money,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Cobrar e finalizar',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.red,
                  onPressed: () {
                    print('finalizar serviço');
                    finishService('finalizado', finish, duration.inMinutes);
                    Navigator.of(context).pop();
                  },
                ),
              ),
//              SimpleDialogOption(
//                onPressed: () { Navigator.pop(context); },
//                child: const Text('State department'),
//              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5.0,
        margin: EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FutureBuilder<DocumentSnapshot>(
                  future: Firestore.instance
                      .collection('users')
                      .document(widget.order.data['uidClient'])
                      .get(),
                  builder: (context, snapshot2) {
                    if (!snapshot2.hasData) {
                      return Container();
                    } else {
                      if (snapshot2.data['img'] == null) {
                        return Flexible(
                          flex: 3,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            maxRadius: 30,
                            minRadius: 30,
                            child: Icon(Icons.person),
                          ),
                        );
                      } else {
                        return Flexible(
                          flex: 3,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapshot2.data['img']),
                            maxRadius: 30,
                            minRadius: 30,
                          ),
                        );
                      }
                    }
                  }),
              SizedBox(
                width: 10,
              ),
              FutureBuilder<DocumentSnapshot>(
                  future: Firestore.instance
                      .collection('users')
                      .document(widget.order.data['uidClient'])
                      .get(),
                  builder: (context, snapshot2) {
                    if (!snapshot2.hasData) {
                      return Container();
                    } else {
                      return Flexible(
                        flex: 3,
                        child: Text(snapshot2.data['name']),
                      );
                    }
                  }),
              SizedBox(
                width: 20.0,
              ),
              Flexible(
                flex: 4,
                child: Column(
                  children: <Widget>[
                    Text(widget.order.data['dateTime'].toDate().day.toString() +
                        '/' +
                        widget.order.data['dateTime']
                            .toDate()
                            .month
                            .toString() +
                        '/' +
                        widget.order.data['dateTime'].toDate().year.toString()),
                    Text(
                        widget.order.data['dateTime'].toDate().hour.toString() +
                            ':' +
                            widget.order.data['dateTime']
                                .toDate()
                                .minute
                                .toString()),
                  ],
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Flexible(
                flex: 6,
                child: FloatingActionButton.extended(
                  heroTag: 'scheduleTime',
                  onPressed: () {
                    print('alterar estado atendimento de...');
                    print(widget.order.data['statusSchedule']);
                    if (statusSchedule == 'agendado') {
                      print('para ... em andamento');
                      startService('em andamento');
                    } else if (statusSchedule == 'em andamento') {
                      print('para .... finalizado');
                      if (widget.order.data['statusPayment'] == 'pago') {
                        _askedToLead();
                      } else if (widget.order.data['statusPayment'] ==
                          'não pago') {
                        _askedToLead();
                      }
//                      showStatus();
//                      changeState('finalizado', 'endService');
                    }
                  },
                  label: statusSchedule == 'agendado'
                      ? Text('Atender')
                      : Text('Finalizar'),
                  icon: statusSchedule == 'agendado'
                      ? Icon(Icons.thumb_up)
                      : Icon(Icons.check),
                  backgroundColor:
                      statusSchedule == 'agendado' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ));
  }
}
