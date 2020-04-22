import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientsTile extends StatelessWidget {
  final DocumentSnapshot client;

  ClientsTile({this.client});




  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.all(3),
//        decoration: BoxDecoration(color: Color.fromRGBO(30, 100, 200, .9)),
        child: FutureBuilder(
            future: Firestore.instance
                .collection('users')
                .document(client.documentID)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
                  leading: Container(
                      padding: EdgeInsets.only(right: 12.0),
                      decoration: new BoxDecoration(
                          border: new Border(
                              right: new BorderSide(
                                  width: 2.0, color: Colors.black45))),
                      child: Hero(
                          tag: "avatar_" + snapshot.data['name'],
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(
                                snapshot.data['img'] == null
                                    ? ''
                                    : snapshot.data['img'], scale: 1.0),
                            backgroundColor: Colors.grey.withAlpha(100),
                            child: snapshot.data['img']== null ? Icon(Icons.person) : Container(),
                          ))),
                  title: Text(
                    snapshot.data['name'],
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      new Flexible(
                          child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            RichText(
                              text: TextSpan(
                                text: snapshot.data['phone'],
                                style: TextStyle(color: Colors.black),
                              ),
                              maxLines: 3,
                              softWrap: true,
                            )
                          ]))
                    ],
                  ),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.phone,
                        color: Colors.black45,
                      ),
                      onPressed: () {
                        print('ligar');
                      }));
            }),
//        child: Row(
//          children: <Widget>[
//            Flexible(
//                flex: 3,
//                child: FutureBuilder<DocumentSnapshot>(
//                    future: Firestore.instance
//                        .collection('users')
//                        .document(client.documentID)
//                        .get(),
//                    builder: (context, snap) {
//                      if (!snap.hasData) return Container();
//                      if (snap.data['img'] == null) {
//                        return CircleAvatar(
//                          radius: 40,
//                          child: Icon(Icons.person),
//                          backgroundColor: Colors.white.withAlpha(100),
//                        );
//                      } else {
//                        return CircleAvatar(
//                          radius: 40,
//                          backgroundImage: NetworkImage(
//                            snap.data['img'],
//                          ),
//                          backgroundColor: Colors.white.withAlpha(100),
//                        );
//                      }
//                    })),
//            SizedBox(
//              width: 10,
//            ),
//            Flexible(
//              flex: 8,
//              child: FutureBuilder(
//                  future: Firestore.instance
//                      .collection('users')
//                      .document(client.documentID)
//                      .get(),
//                  builder: (context, snap) {
//                    if (!snap.hasData) return Container();
//                    return Column(
//                      children: <Widget>[
//                        Row(
//                          children: <Widget>[
//                            Text(
//                              snap.data['name'],
//                              style: TextStyle(color: Colors.white),
//                            ),
//                            snap.data['lastName'] != null
//                                ? Text(
//                                    snap.data['lastName'],
//                                    style: TextStyle(color: Colors.white),
//                                  )
//                                : Container(),
//                          ],
//                        ),
//                        SizedBox(
//                          height: 10,
//                        ),
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Text(
//                              snap.data['phone'],
//                              style: TextStyle(color: Colors.white),
//                            ),
//                          ],
//                        ),
//                      ],
//                    );
//                  }),
//            ),
//          ],
//        ),
      ),
    );
  }
}
