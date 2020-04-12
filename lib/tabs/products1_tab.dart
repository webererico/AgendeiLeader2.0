import 'package:agendei/widgets/category_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductsTab extends StatefulWidget {
  @override
  _ProductsTabState createState() => _ProductsTabState();
}


class _ProductsTabState extends State<ProductsTab> with AutomaticKeepAliveClientMixin{


  getUserUID() async {
//    FirebaseUser user = await FirebaseAuth.instance.currentUser();
//    print(user.uid);
  }

  @override
  Widget build(BuildContext context){
    super.build(context);
//    String uid = getUserUID();

    return FutureBuilder<QuerySnapshot>(
        future: Firestore.instance.collection('serviços').getDocuments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),

              ),
            );
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return CategoryTile(
                  snapshot.data.documents[index]
              );
            },
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}
