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
  var end;

  @override
  void initState() {
    super.initState();
    setState(() {
      statusSchedule = widget.order.data['statusSchedule'];
      print(statusSchedule);
      print('entrou');
    });
  }

  changeState(String status, String variable) async {
    start = new DateTime.now();
    final Map<String, dynamic> data = {
      'statusSchedule': status,
      variable: Timestamp.fromDate(start)
    };
    Firestore.instance
        .collection('users')
        .document(widget.order.data['uidClient'])
        .collection('orders')
        .document(widget.order.documentID)
        .updateData(data);
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

  Future<void> _askedToLead() async {
    end = new DateTime.now();
    final _end = Timestamp.fromDate(end).toDate();
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
//              FutureBuilder<DocumentSnapshot>(
//                  future: Firestore.instance
//                      .collection('companies')
//                      .document(widget.order.data['uidCompany']).collection('employees').document(widget.order.data['uidEmployee'])
//                      .get(),
//                  builder: (context, snapshot2) {
//                    if (!snapshot2.hasData) {
//                      return Container();
//                    } else {
//                      return Flexible(
//                        flex: 3,
//                        child: Text(snapshot2.data['fullName']),
//                      );
//                    }
//                  }),
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
                    print(widget.order.data['statusPayment']);
                    if (statusSchedule == 'agendado') {
                      print('alterar estado atendimento: agendado');
                      changeState('em andamento', 'startService');
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
