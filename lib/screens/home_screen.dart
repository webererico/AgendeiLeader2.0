
import 'package:agendei/blocs/user_bloc.dart';
import 'package:agendei/tabs/schedules_tab.dart';
import 'package:agendei/tabs/calendars_tab.dart';
import 'package:agendei/tabs/configs_tab.dart';
import 'package:agendei/tabs/employees_tab.dart';
import 'package:agendei/tabs/services_tab.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int _page = 0;
  UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _userBloc = UserBloc();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Color.fromARGB(255, 15, 76, 129),
            primaryColor: Colors.white,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: TextStyle(color: Colors.white54))),
        child: BottomNavigationBar(
          currentIndex: _page,
          onTap: (p) {
            _pageController.animateToPage(p,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              title: Text('Agendamentos'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              title: Text('Agendas'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text('RH'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text('Serviços'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('Configurações'),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: BlocProvider<UserBloc>(
          bloc: _userBloc,
          child: PageView(
            controller: _pageController,
            onPageChanged: (p) {
              setState(() {
                _page = p;
              });
            },
            children: <Widget>[
              SchedulesTab(),
              CalendarTab(),
              EmployeeTab(),
              ServicesTab(),
              ConfigsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
