import 'package:agendei/screens/employee_screen.dart';
import 'package:agendei/widgets/employees_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class EmployeeTab extends StatefulWidget {
  @override
  _EmployeeTabState createState() => _EmployeeTabState();
}

class _EmployeeTabState extends State<EmployeeTab> with AutomaticKeepAliveClientMixin {

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
        future: Firestore.instance.collection('companies').document(uid).collection('employees').getDocuments(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
              
            }else{
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index){
                    return EmployeesTile(
                      uidCompany: uid,
                      employees: snapshot.data.documents[index],
                    );

//                      (snapshot.data.documents[index]), (uid),
//                    );
                  }
              );
            }
          }
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tagEmployees',
          onPressed: (){
            print('Criar novo funcionario');
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EmployeeScreen(uidCompany: uid,)));
          },
        backgroundColor: Colors.green,
        child: Icon(Icons.person_add),

      ),
    );
  }

  @override
  bool get wantKeepAlive {
    return true;
  }


}
