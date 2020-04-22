import 'package:agendei/screens/editCalendar_screen.dart';
import 'package:agendei/screens/schedule_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CalendarsTile extends StatelessWidget {
  final String uidCompany;
  final DocumentSnapshot calendar;

  CalendarsTile({this.calendar, this.uidCompany});

  TextStyle _style() {
    return TextStyle(backgroundColor: Colors.green, color: Colors.white);
  }

  TextStyle _style2() {
    return TextStyle(
      backgroundColor: Colors.white,
    );
  }

  Widget _sub(DateTime start, DateTime end) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(calendar.data['seg'] == true ? 'SEG' : 'SEG',
                style: calendar.data['seg'] == true ? _style() : _style2()),
            Text(calendar.data['ter'] == true ? 'TER' : 'TER',
                style: calendar.data['ter'] == true ? _style() : _style2()),
            Text(calendar.data['qua'] == true ? 'QUA' : 'QUA',
                style: calendar.data['qua'] == true ? _style() : _style2()),
            Text(calendar.data['qui'] == true ? 'QUI' : 'QUI',
                style: calendar.data['qui'] == true ? _style() : _style2()),
            Text(calendar.data['sex'] == true ? 'SEX' : 'SEX',
                style: calendar.data['sex'] == true ? _style() : _style2()),
            Text(calendar.data['sab'] == true ? 'SAB' : 'SAB',
                style: calendar.data['sab'] == true ? _style() : _style2()),
            Text(calendar.data['dom'] == true ? 'DOM' : 'DOM',
                style: calendar.data['dom'] == true ? _style() : _style2()),
          ],
        ),
        Row(
          children: <Widget>[
            Text('Início às: ${start.hour}:${start.minute}'),
            Text(' com Término às: ${end.hour}:${end.minute}'),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Timestamp start = calendar.data['startTime'];
    Timestamp end = calendar.data['endTime'];
    return Padding(
        padding: EdgeInsets.all(7.0),
        child: Card(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  "${calendar.data['name']}",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                subtitle: _sub(start.toDate(), end.toDate()),
              ),
              Divider(),
              ButtonBar(
                buttonHeight: 2,
                buttonMinWidth: 3,

                children: <Widget>[
                  FlatButton(
                    child: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EditCalendarScreen(
                         uidCalendar: calendar.documentID,
                         uidCompany: uidCompany,
                      )));
                      /* ... */
                    },
                  ),
                  FlatButton(
                    child: Icon(
                      Icons.schedule,
                    ),
                    onPressed: () {
                      /* ... */
                    },
                  ),
                  FlatButton(
                    child: Icon(Icons.calendar_today),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ScheduleScreen(uidCalendar: calendar.documentID,uidCompany:uidCompany, service: calendar.data['uidService'],)));
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
