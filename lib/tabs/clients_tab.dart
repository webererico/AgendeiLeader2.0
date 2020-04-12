import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  String uidCompany;

  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uidCompany = user.uid.toString();
    return uidCompany;
  }

  @override
  void initState() {
    getUID().then((results) {
      setState(() {
        uidCompany = results;
        print('uidCompany: ' + uidCompany);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Pesquisar cliente',
              hintStyle: TextStyle(color: Colors.white),
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        FutureBuilder<QuerySnapshot>(
            future: Firestore.instance
                .collection('companies')
                .document(uidCompany)
                .collection('clients')
                .getDocuments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                );
              } else {
                for (int i = 0; i < snapshot.data.documents.length; i++) {
                  print(snapshot.data.documents[i].documentID);
                  return Card(
                    elevation: 2.0,
                    margin: EdgeInsets.all(15.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(30, 100, 200, .9)),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                              flex: 3,
                              child: FutureBuilder(
                                  future: Firestore.instance
                                      .collection('users')
                                      .document(
                                          snapshot.data.documents[i].documentID)
                                      .get(),
                                  builder: (context, snap) {
                                    if (!snap.hasData) return Container();
                                    return CircleAvatar(
                                      radius: 40,
                                      backgroundImage: snap.data['img'] == null
                                          ? Icon(Icons.person)
                                          : NetworkImage(
                                              snap.data['img'],
                                            ),
                                      backgroundColor:
                                          Colors.white.withAlpha(100),
                                    );
                                  })),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              flex: 8,
                              child: FutureBuilder(
                                  future: Firestore.instance
                                      .collection('users')
                                      .document(
                                          snapshot.data.documents[i].documentID)
                                      .get(),
                                  builder: (context, snap) {
                                    if (!snap.hasData) return Container();
                                    return Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              snap.data['name'] ,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            snap.data['lastName'] != null
                                                ? Text(
                                                    snap.data['lastName'],
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              snap.data['phone'],
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  })),
                        ],
                      ),
                    ),
                  );
                }
                return Container();
              }
            }),
      ],
    );
  }
}
