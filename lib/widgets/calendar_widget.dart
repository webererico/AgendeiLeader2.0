//import 'dart:html';

import 'package:agendei/widgets/schedule_tile.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};

class CalendarTabWidget extends StatefulWidget {
  @override
  _CalendarTabWidgetState createState() => _CalendarTabWidgetState();
}

class _CalendarTabWidgetState extends State<CalendarTabWidget>
    with TickerProviderStateMixin {
  Map<DateTime, List<DocumentSnapshot>> _events = {};
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  DateTime _selectedDay = DateTime.now();
  List<DocumentSnapshot> allOrdersList = List<DocumentSnapshot>();
  List<DocumentSnapshot> ordersFinal = List<DocumentSnapshot>();

  Future<List<DocumentSnapshot>> getCalendarsOrders() async {
//    _events.clear();
    print('colocando calendários em lista ...');
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    List<DocumentSnapshot> allOrders = List<DocumentSnapshot>();
    QuerySnapshot calendars = await Firestore.instance
        .collection('companies')
        .document(user.uid)
        .collection('calendars')
        .getDocuments();
    List<DocumentSnapshot> calendarsList = calendars.documents;
    print('quantidade calendarios: ' + calendarsList.length.toString());
    for (int index = 0; index < calendarsList.length; index++) {
      print(calendarsList[index].documentID);
      QuerySnapshot orders = await Firestore.instance
          .collection('companies')
          .document(user.uid)
          .collection('calendars')
          .document(calendarsList[index].documentID)
          .collection('orders')
          .getDocuments();
      print('quandidade de orders: ' + orders.documents.length.toString());
      if (orders.documents.length != 0) {
        List<DocumentSnapshot> ordersList = orders.documents;
        for (int i = 0; i < ordersList.length; i++) {
          print('order: ' + ordersList[i].documentID);
          Timestamp date = ordersList[i].data['dateTime'];
          print('data da Order: ' + date.toDate().toString());
          allOrders.clear();
          if (_events.containsKey(date.toDate())) {
            ordersFinal = _events[date.toDate()]?? [];
            ordersFinal.add(ordersList[i]);
            allOrders = ordersFinal;
          } else {
            allOrders.add(ordersList[i]);
          }
          _events.putIfAbsent(date.toDate(), () => allOrders);
        }
      }
      print(_events.toString());
    }

    return allOrders;
  }

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
    getCalendarsOrders().then((result) {
      setState(() {
        allOrdersList = result;
      });
    });

    _selectedEvents = _events[_selectedDay] ?? [];
    for (int i = 0; i < _selectedEvents.length; i++) {
      print(_selectedEvents[i].data['statusSchedule']);
    }
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedDay = day;
      getCalendarsOrders();
      _selectedEvents = events;
      print('dia selecionado' + _selectedDay.toIso8601String());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.grey,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          // _buildTableCalendarWithBuilders(),
          Divider(
            color: Colors.black54,
          ),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      locale: 'pt_BR',
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.blue[600],
        todayColor: Colors.blue[200],
        markersColor: Colors.lightBlueAccent,
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.blueAccent[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        return ScheduleTile(
          uidCalendar: _selectedEvents[index].data['uidCalendar'],
          order: _selectedEvents[index],
        );
      },
    );
  }
}
