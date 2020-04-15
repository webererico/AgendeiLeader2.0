import 'package:agendei/widgets/schedule_tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllSchedulesTabWidget extends StatefulWidget {
  @override
  _AllSchedulesTabWidgetState createState() => _AllSchedulesTabWidgetState();
}

class _AllSchedulesTabWidgetState extends State<AllSchedulesTabWidget> {
  List<DocumentSnapshot> allOrdersList = List<DocumentSnapshot>();




  Future<List<DocumentSnapshot>> getCalendarsOrders() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    List<DocumentSnapshot> allOrders = List<DocumentSnapshot>();
    QuerySnapshot calendars = await Firestore.instance
        .collection('companies')
        .document(user.uid)
        .collection('calendars')
        .getDocuments();
    List<DocumentSnapshot> calendarsList = calendars.documents;
    print('quantidade calendarios: '+ calendarsList.length.toString());
    for (int index = 0; index < calendarsList.length; index++) {
      print(calendarsList[index].documentID);
      QuerySnapshot orders = await Firestore.instance
          .collection('companies')
          .document(user.uid)
          .collection('calendars')
          .document(calendarsList[index].documentID)
          .collection('orders').where('statusSchedule', isEqualTo: 'agendado')
          .getDocuments();
      print('quandidade de orders: '+orders.documents.length.toString());
      if(orders.documents.length != 0){
        List<DocumentSnapshot> ordersList = orders.documents;
        for (int i = 0; i < ordersList.length; i++) {
          print('order: '+ordersList[i].documentID);
          allOrders.add(ordersList[i]);
          print('allOrders: '+allOrders.length.toString());
        }
      }

    }
    return allOrders;
  }

  @override
  void initState() {
    super.initState();
    getCalendarsOrders().then((result) {
      setState(() {
        allOrdersList  = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: allOrdersList.length,
      itemBuilder: (context, index) {
        return ScheduleTile(
          uidCalendar: allOrdersList[index].data['uidCalendar'],
          order: allOrdersList[index],
        );
      },
    );
  }
}
