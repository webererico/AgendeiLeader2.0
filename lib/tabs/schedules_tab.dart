import 'package:agendei/screens/newSchedule_screen.dart';
import 'package:agendei/tabs/clients_tab.dart';
import 'package:agendei/widgets/allSchedulesTab_widget.dart';
import 'package:agendei/widgets/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulesTab extends StatefulWidget {
  @override
  _SchedulesTabState createState() => _SchedulesTabState();
}

class _SchedulesTabState extends State<SchedulesTab> {
  String uidCompany;
  String companyName;
  PageController _pageController;


  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid.toString();
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection('companies').document(uid).get();
    companyName =  documentSnapshot.data['name'];
    uidCompany = uid;
    return uid;
  }



  @override
  void initState() {
    super.initState();
    getUID().then((result){
      setState(() {
        uidCompany = result;
      });
    });
    print(uidCompany);
  }




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
              title: companyName == null ? Text('') : Text(companyName),
              centerTitle: true,
              actions: [
                IconButton(
                    icon: Icon(Icons.add), onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> NewScheduleScreen()));
                }
                )
              ],
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    icon: Icon(Icons.calendar_today),
                  ),
                  Tab(
                    icon: Icon(Icons.calendar_view_day),
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
                CalendarTabWidget(),
                AllSchedulesTabWidget(),
                ClientsTab(uidCompany: uidCompany),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
