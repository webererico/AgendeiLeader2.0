import 'package:agendei/screens/service_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agendei/widgets/services_tile.dart';

class ServicesTab extends StatefulWidget {
  @override
  _ServicesTabState createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> with AutomaticKeepAliveClientMixin{
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
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('companies')
              .document(uid)
              .collection('services')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            }else {
              if(snapshot.data.documents.length ==0){
                return Center(child: Text('Você não possui serviços cadastrados'),);
              }
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return ServicesTile(
                    (snapshot.data.documents[index]), (uid),
                  );
                },
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tagServices',
        onPressed: (){
          print('criar novo servico');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ServiceScreen(
                uidCompany: uid,

              )));
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),

    );


  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
