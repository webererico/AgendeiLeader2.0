import 'package:agendei/tabs/clients_tab.dart';
import 'package:agendei/widgets/allSchedulesTab_widget.dart';
import 'package:agendei/widgets/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchedulesTab extends StatefulWidget {
  @override
  _SchedulesTabState createState() => _SchedulesTabState();
}

class _SchedulesTabState extends State<SchedulesTab> {
  String uidCompany;
  PageController _pageController;

  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid.toString();
    uidCompany = uid;
    return uid;
  }

  @override
  void initState() {
    getUID().then((result){
      setState(() {
        uidCompany = result;
      });
    });
    super.initState();
    print(uidCompany);
  } //  @override
//  void initState() {
//    super.initState();
//    getUID().then((result) {
//      setState(() {
//        uidCompany = result;
//      });
//    });
//    print('uidCompany: '+uidCompany);
//  }



  @override
  Widget build(BuildContext context) {

    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
//              title: Text('Agendamentos'),
//              centerTitle: true,
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    icon: Icon(Icons.calendar_view_day),
                  ),
                  Tab(
                    icon: Icon(Icons.calendar_today),
                  ),
                  Tab(
                    icon: Icon(Icons.people_outline),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                AllSchedulesTabWidget(uidCompany: uidCompany,),
                CalendarTabWidget(uidCompany: uidCompany,),
                UsersTab(),
              ],
            ),
          ),
        ),
      ],
//      backgroundColor: Color,
    );
  }
}
