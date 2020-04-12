import 'package:agendei/screens/calendar_screen.dart';
import 'package:agendei/widgets/calendars_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CalendarTab extends StatefulWidget {
  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab>
    with AutomaticKeepAliveClientMixin {
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = '';

  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid.toString();
    return uid;
  }

  @override
  void initState() {
    super.initState();
    getUID().then((results) {
      setState(() {
        uid = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: FutureBuilder<QuerySnapshot>(
          future: Firestore.instance
              .collection('companies')
              .document(uid)
              .collection('calendars')
              .getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return CalendarsTile(
                      calendar: snapshot.data.documents[index],
                      uidCompany: uid,
                    );
                  });
            }
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tagCalendars',
        onPressed: () {
          print('novo calendário');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => CalendarScreen()));
        },
        backgroundColor: Colors.green,
        
        child: Icon(Icons.calendar_view_day),
      ),
    );
  }




  @override
  bool get wantKeepAlive {
    return true;
  }
}
