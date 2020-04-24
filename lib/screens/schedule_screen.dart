import 'package:agendei/widgets/schedule_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  final String uidCalendar;
  final String uidCompany;
  final String service;

  ScheduleScreen({this.uidCalendar, this.uidCompany, this.service, Key key})
      : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String dropdownValue = 'Data';
  String serviceName;

  getServiceName () async{
    final DocumentSnapshot documentSnapshot = await Firestore.instance.collection('companies').document(widget.uidCompany).collection('services').document(widget.service).get();
    return documentSnapshot.data['name'];
  }


  @override
  void initState() {

    getServiceName().then((result){
      setState(() {
        serviceName = result;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: serviceName == null ?  Text('') : Text(serviceName),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: DropdownButton<String>(
//              value: dropdownValue,
              icon: Icon(
                Icons.format_line_spacing,
                color: Colors.white,
              ),
              iconSize: 20,
              isExpanded: false,
              hint: Text(
                'Filtrar',
                style: TextStyle(color: Colors.white),
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                  print(dropdownValue);
                });
              },
              items: <String>[
                'Data',
                'Status',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          FutureBuilder<QuerySnapshot>(
              future: Firestore.instance
                  .collection('companies')
                  .document(widget.uidCompany)
                  .collection('calendars')
                  .document(widget.uidCalendar)
                  .collection('orders')
                  .orderBy('dateTime', descending: true)
                  .getDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  print(widget.uidCompany);
                  print(widget.uidCalendar);
                  print(snapshot.data.documents.length);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return ScheduleTile(
                        uidCalendar: widget.uidCalendar,
                        order: snapshot.data.documents[index],
                      );
                    },
                  );
                }
              }),
        ],
      ),
    );
  }
}
