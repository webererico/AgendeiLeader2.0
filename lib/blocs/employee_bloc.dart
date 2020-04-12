import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class EmployeeBloc extends BlocBase {
  String uidCompany;
  final _dataController = BehaviorSubject<Map>();
  final _loadingController = BehaviorSubject<bool>();
  final _createdController = BehaviorSubject<bool>();

  Stream<Map> get outData => _dataController.stream;

  Stream<bool> get outLoading => _loadingController.stream;

  Stream<bool> get outCreated => _createdController.stream;

  String uidEmployee;
  DocumentSnapshot employee;
  Map<String, dynamic> unsavedData;

  EmployeeBloc({this.uidEmployee, this.uidCompany, this.employee}) {
    if (employee != null) {
      unsavedData = Map.of(employee.data);
      _createdController.add(true);
    } else {
      unsavedData = {
        'fullName': null,
        'cpf': null,
        'phone': null,
        'adress': null,
        'email': null,
        'function': null,
        'birth': null,
        'gender': null,
        'img': null
      };
      _createdController.add(false);
    }
    _dataController.add(unsavedData);
  }

  void saveFullName(String text) {
    unsavedData['fullName'] = text;
  }

  void saveCpf(String text) {
    unsavedData['cpf'] = text;
  }

  void savePhone(String text) {
    unsavedData['phone'] = text;
  }

  void saveAdress(String text) {
    unsavedData['adress'] = text;
  }

  void saveEmail(String text) {
    unsavedData['email'] = text;
  }

  void saveFuncion(String text) {
    unsavedData['function'] = text;
  }

  void saveBirth(String text) {
    unsavedData['birth'] = text;
  }

  void saveGender(String text) {
    unsavedData['gender'] = text;
  }

  void saveImg(String text) {
    unsavedData['img'] = text;
  }

  Future<bool> saveEmployee(String uidCompany) async {
    _loadingController.add(true);
    try {
      if (employee != null) {
        await employee.reference.updateData(unsavedData);
      } else {
        DocumentReference dr = await Firestore.instance
            .collection('companies')
            .document(uidCompany)
            .collection('employees')
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

  void deleteEmployee() {
    employee.reference.delete();
  }

  @override
  void dispose() {
    _dataController.close();
    _loadingController.close();
    _createdController.close();
  }
}
