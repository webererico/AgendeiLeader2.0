import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class ProfileBloc extends BlocBase {
  String uidCompany;
  final _dataController = BehaviorSubject<Map>();
  final _loadingController = BehaviorSubject<bool>();
  final _createdController = BehaviorSubject<bool>();

  Stream<Map> get outData => _dataController.stream;

  Stream<bool> get outLoading => _loadingController.stream;

  Stream<bool> get outCreated => _createdController.stream;

  DocumentSnapshot company;
  Map<String, dynamic> unsavedData;

  ProfileBloc({this.uidCompany, this.company}) {
    if (company != null) {
      unsavedData = Map.of(company.data);
      _createdController.add(true);
    } else {
      unsavedData = {
        'name': null,
        'cnpj': null,
        'adress': null,
        'email': null,
        'phone': null,
        'fullNameBoss': null,
        'cpfBoss': null,
        'uidCategory': null,
        'img': null,
      };
      _createdController.add(false);
    }
    _dataController.add(unsavedData);
  }

  void saveName(String text) {
    unsavedData['name'] = text;
  }

  void saveCNPJ(String text) {
    unsavedData['cnpj'] = text;
  }

  void saveAdress(String text) {
    unsavedData['adress'] = text;
  }

  void saveEmail(String text) async {
    unsavedData['email'] = text;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.updateEmail(text);
  }

  void savePhone(String text) {
    unsavedData['phone'] = text;
  }

  void saveCpfBoss(String text) {
    unsavedData['cpfBoss'] = text;
  }

  void saveFullNameBoss(String text) {
    unsavedData['fullNameBoss'] = text;
  }

  void saveImg(String text) {
    unsavedData['img'] = text;
  }

  void saveUidCategory(String text) {
    unsavedData['uidCategory'] = text;
  }

  Future<bool> saveCompany(String uidCompany) async {
    _loadingController.add(true);
    try {
      await company.reference.updateData(unsavedData);
      _loadingController.add(false);
      _loadingController.add(true);
      return true;
    } catch (e) {
      _loadingController.add(false);
      return false;
    }
  }

  void deleteCompany() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    company.reference.delete();
    user.delete();

  }

  @override
  void dispose() {
    _dataController.close();
    _loadingController.close();
    _createdController.close();
  }
}
