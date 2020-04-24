import 'package:agendei/screens/employee_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeesTile extends StatelessWidget {
  final DocumentSnapshot employees;
  final uidCompany;

  EmployeesTile({this.employees, this.uidCompany});


  @override
  Widget build(BuildContext context) {
    return Card(
//      key: ValueKey(record.name),
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 15, 76, 129)),
        child: ListTile(
          contentPadding:
          EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      right: new BorderSide(width: 2.0, color: Colors.white24))),
              child: Hero(
                  tag: "avatar_" + employees.data['fullName'],
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(employees.data['img'] == null ? '' : employees.data['img']),
                    backgroundColor: Colors.white.withAlpha(100),
                  )
              )
          ),
          title: Text(
            employees.data['fullName'],
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              new Flexible(
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: employees.data['function'],
                            style: TextStyle(color: Colors.white),
                          ),
                          maxLines: 3,
                          softWrap: true,
                        )
                      ]))
            ],
          ),
          trailing:
              IconButton(
                  icon:  Icon(Icons.edit, color: Colors.white, size: 30.0),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EmployeeScreen(
                      uidCompany: uidCompany,
                      employee: employees,
                      uidEmployee: employees.documentID,
                    )));
                  }
              )
        ),
      ),
    );

//    return Container(
//      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//      child: Card(
//        child: Text(employees.data['fullName']),
//      ),
//    );
  }
}
