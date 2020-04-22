
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class CalendarBloc extends BlocBase{
  String uidCompany;
  String uidService;
  String uidEmployee;

  final _dataController = BehaviorSubject<Map>();
  final _loadingController = BehaviorSubject<bool>();
  final _createdController = BehaviorSubject<bool>();

  Stream<Map> get outData => _dataController.stream;
  Stream<bool> get outLoading => _loadingController.stream;
  Stream<bool> get outCreated => _createdController.stream;

  DocumentSnapshot calendar;
  Map<String, dynamic> unsavedData;

  CalendarBloc({this.uidCompany, this.uidService, this.uidEmployee, this.calendar}){
    if(calendar != null){
      unsavedData = Map.of(calendar.data);
      _createdController.add(true);
    }else{
      unsavedData ={
        'title': null,
        'days': null,

      };
      _createdController.add(false);
    }
    _dataController.add(unsavedData);
  }

//  REPETIR FUNCAO PARA DEMAIS CAMPOS
  void saveAlgo(String text){
    unsavedData['algo'] = text;
  }

  Future<bool> saveCalendar(String uidCompany) async{
    _loadingController.add(true);
    try{
      if(calendar != null){
        await calendar.reference.updateData(unsavedData);
      }else{
        DocumentReference dr = await Firestore.instance.collection('companies').document(uidCompany).collection('calendars').add(Map.from(unsavedData));
        await dr.updateData(unsavedData);
      }
      _loadingController.add(false);
      _createdController.add(true);
      return true;
    }catch(e){
      _loadingController.add(false);
      return false;
    }
  }

  void deleteCalendar(){
    calendar.reference.delete();
  }




  @override
  void dispose() {
    _loadingController.close();
    _dataController.close();
    _createdController.close();

  }


}