import 'package:agendei/widgets/clients_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClientsTab extends StatefulWidget {
  final String uidCompany;

  ClientsTab({this.uidCompany, Key key}) : super(key: key);

  @override
  _ClientsTabState createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
//  String uidCompany;

//  getUID() async {
//    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
//    final uidCompany = user.uid.toString();
//    print('uidCompany: '+ uidCompany);
//    return uidCompany;
//  }

  @override
  void initState() {
    super.initState();
    print(widget.uidCompany);
//    getUID().then((results) {
//      setState(() {
//        uidCompany = results;
//      });
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              fillColor: Colors.grey,
              hintText: 'Buscar cliente',
              hintStyle: TextStyle(color: Colors.black),
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('companies')
                .document(widget.uidCompany)
                .collection('clients')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                );
              } else {
                print('quantidade de clientes: ' +
                    snapshot.data.documents.length.toString());
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return ClientsTile(
                      client: snapshot.data.documents[index],
                    );
                  },
                );
              }
            }),
      ],
    );
  }
}
