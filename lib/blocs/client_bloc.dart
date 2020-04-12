
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class ClientBloc extends BlocBase {
  final _clientController = BehaviorSubject();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, Map<String, dynamic>> _clients = {};

  Firestore _firestore = Firestore.instance;

  clientBloc() {
    _addClientListener();
  }



  void _addClientListener()  async{
    final FirebaseUser user = await _auth.currentUser();
    final uidCompany = user.uid;
//    print(uidCompany);

    _firestore.collection('companies').document(uidCompany).collection('clients').snapshots().listen((snapshot) {
      snapshot.documentChanges.forEach((change) {
        String uid = change.document.documentID;
        print(uid);
        switch (change.type) {
          case DocumentChangeType.added:
            _clients[uid] = change.document.data;
            break;
          case DocumentChangeType.modified:
            _clients[uid].addAll(change.document.data);
            break;

          case DocumentChangeType.removed:
            _clients.remove(uid);
            break;
        }
      });
    });
  }

//  void _subscribeToOrderServices(String uid) async{
//    _firestore
//        .collection('users')
//        .document(uid)
//        .collection('orderServices')
//        .snapshots()
//        .listen((services) {
//
//      int numServices = services.documents.length;
//
//      for (DocumentSnapshot d in services.documents) {
//        DocumentSnapshot serviceOrder = await _firestore
//            .collection('orderServices')
//            .document(d.documentID)
//            .get();
//
//        numServices = .
//      }
//    });
//  }

  @override
  void dispose() {
    _clientController.close();
  }
}
