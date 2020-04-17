import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ServiceBloc extends BlocBase {
  String uidCompany;
  final _dataController = BehaviorSubject<Map>();
  final _loadingController = BehaviorSubject<bool>();
  final _createdController = BehaviorSubject<bool>();

  Stream<Map> get outData => _dataController.stream;

  Stream<bool> get outLoading => _loadingController.stream;

  Stream<bool> get outCreated => _createdController.stream;

  String uidService;
  DocumentSnapshot service;
  Map<String, dynamic> unsavedData;

  ServiceBloc({this.uidService, this.uidCompany, this.service}) {
    if (service != null) {
      unsavedData = Map.of(service.data);
      _createdController.add(true);
    } else {
      unsavedData = {
        'name': null,
        'description': null,
        'price': null,
        'duration': null,
        'public': null,
      };
      _createdController.add(false);
    }
    _dataController.add(unsavedData);
  }

  void saveName(String name) {
    unsavedData['name'] = name;
  }

  void saveDescription(String description) {
    unsavedData['description'] = description;
  }

  void savePrice(String price) {
    unsavedData['price'] = price;
  }

  void saveDuration(int duration) {
    if(duration == 0){
      duration = 1;
    }
    unsavedData['duration'] = duration;
  }

  void savePublic(String public) {
    unsavedData['public'] = public;
  }


  Future<bool> saveService(String uidCompany) async {
    _loadingController.add(true);
    try {
      if (service != null) {
//      await _uploadImages(service.documentID);
        await service.reference.updateData(unsavedData);
      } else {
        DocumentReference dr = await Firestore.instance
            .collection('companies')
            .document(uidCompany)
            .collection('services')
            .add(Map.from(unsavedData));
        await dr.updateData(unsavedData);
      }
      _loadingController.add(false);
      _createdController.add(true);
      return true;
    } catch (e) {
      _loadingController.add(false);
      return false;
    }
  }

  void deleteService() {
    service.reference.delete();
  }

//  Future _uploadImages(String serviceId) async{
//    for(int i = 0; i<unsavedData['images'].length; i++){
//      if(unsavedData['images'][i] is String) continue;
//        StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child(categoryId).putFile(unsavedData['images'][i]);
//        StorageTaskSnapshot  s = await uploadTask.onComplete;
//        String downloadUrl = await s.ref.getDownloadURL();
//        unsavedData['images'][i] = downloadUrl;
//    }
//  }

  @override
  void dispose() {
    _dataController.close();
    _loadingController.close();
    _createdController.close();
  }
}
