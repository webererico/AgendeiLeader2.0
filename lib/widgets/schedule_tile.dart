import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleTile extends StatefulWidget {
  final String uidCalendar;
  final DocumentSnapshot order;


  ScheduleTile({this.uidCalendar, this.order, Key key}) : super(key: key);

  @override
  _ScheduleTileState createState() => _ScheduleTileState();
}

class _ScheduleTileState extends State<ScheduleTile> {
  String statusSchedule;
  var start;
  var finish;

  @override
  void initState() {
    super.initState();
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
    print('uidCompany'+widget.order.data['uidCompany']);
    print('uidcalendar'+widget.uidCalendar);
    print(widget.order.documentID);
    Firestore.instance
        .collection('companies')
        .document(widget.order.data['uidCompany'])
        .collection('calendars')
        .document(widget.uidCalendar)
        .collection('orders')
        .document(widget.order.documentID)
        .updateData(data);
    setState(() {
      statusSchedule = status;
    });
  }

  finishService(String status, DateTime finish) async{
    final Map<String, dynamic> data = {
      'statusSchedule': status,
      'finishService': Timestamp.fromDate(finish),
      'evalueationService': null,
      'evalueationEmployee': null
    };
    DocumentSnapshot documentSnapshotUser = await Firestore.instance
        .collection('users')
        .document(widget.order.data['uidClient'])
        .collection('orders')
        .document(widget.order.documentID).get();
    documentSnapshotUser.data.update('statusSchedule', (value) => status);
    documentSnapshotUser.data.update('finishService', (value) => Timestamp.fromDate(finish));
    Firestore.instance.collection('users').document(widget.order.data['uidClient']).collection('orders').document(documentSnapshotUser.documentID).setData(documentSnapshotUser.data);
    Firestore.instance
        .collection('users')
        .document(widget.order.data['uidClient'])
        .collection('orders')
        .document(widget.order.documentID).delete();
    print('salvou no finishOrders do usuário');


    DocumentSnapshot documentSnapshotCompany = await Firestore.instance
        .collection('companies')
        .document(widget.order.data['uidCompany'])
        .collection('calendars')
        .document(widget.uidCalendar)
        .collection('orders')
        .document(widget.order.documentID)
        .get();
    documentSnapshotCompany.data.update('statusSchedule', (value) => status);
    documentSnapshotCompany.data.update('finishService', (value) => Timestamp.fromDate(finish));
    Firestore.instance.collection('companies').document(widget.order.data['uidCompany']).collection('services').document(widget.order.data['uidService']).collection('history').document(documentSnapshotCompany.documentID).setData(documentSnapshotCompany.data);
    Firestore.instance
        .collection('companies')
        .document(widget.order.data['uidCompany'])
        .collection('calendars')
        .document(widget.uidCalendar)
        .collection('orders')
        .document(widget.order.documentID).delete();
    print('salvou no historico do servico da empresa');

    setState(() {
      statusSchedule = status;
    });
    setState(() {
      statusSchedule = status;
    });
  }

  Future<void> _askedToLead() async {
    var finish  = new DateTime.now();
    final _end = Timestamp.fromDate(finish).toDate();
    final difference = _end.difference(Timestamp.fromDate(start).toDate());
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(10.0),
            title: const Text(
              'Serviço Finalizado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              Text('Duração: ' + difference.inMinutes.toString() + ' minutoss'),
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
                    finishService('finalizado', finish);
                  },
                ),
              ),
//              SimpleDialogOption(
//                onPressed: () { Navigator.pop(context); },
//                child: const Text('State department'),
//              ),
            ],
          );
        })) {
    }
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
                    print('alterar estado atendimento');
                    print(widget.order.data['statusSchedule']);
                    if (statusSchedule == 'agendado') {
                      print('alterar estado atendimento: em andamento');
                      startService('em andamento');
                    } else if (statusSchedule == 'em andamento') {
                      print('alterar estado atendimento: finalizado');
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
