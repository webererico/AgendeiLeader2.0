import 'package:flutter/material.dart';

class ClientsTile extends StatelessWidget {
  final client;

  ClientsTile({this.client});




  @override
  Widget build(BuildContext context) {
//      return Center(child: CircularProgressIndicator(),);
////    }else{
//    return FutureBuilder<DocumentSnapshot>(
//      future: Firestore.instance.collection('users').document(uidClient).get(),
//      builder: (context, snashot) {
//        if (!snashot.hasData)
//          return Center(
//            child: CircularProgressIndicator(),
//          );
        return ListTile(
          onTap: () {},
          title: Text(
            client['name']+ ' ' + client['lastName'],
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'tittle',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'Serviços: 0 ',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Aniversario: 18/06/1996 ',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
//      },
//    );

//          }
//        });
  }
}
