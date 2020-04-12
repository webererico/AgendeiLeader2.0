import 'dart:async';
import 'package:agendei/validators/login_validators.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

//enum LoginState { IDLE, LOADING, SUCCESS, FAIL, WRONG_PASSWORD, NO_EMAIL }
enum LoginState { IDLE, LOADING, SUCCESS, FAIL}

class LoginBloc extends BlocBase with LoginValidators {
  final _emailController = BehaviorSubject<String>();
  final _passController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();

  Stream<String> get outEmail =>
      _emailController.stream.transform(validateEmail);

  Stream<String> get outPass => _passController.stream.transform(validatePass);

  Stream<LoginState> get outState => _stateController.stream;

  Function(String) get changeEmail => _emailController.sink.add;

  Function(String) get changePass => _passController.sink.add;

  StreamSubscription _subscription;

  LoginBloc() {
//    FirebaseAuth.instance.signOut();
    _subscription =
        FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
      if (user != null) {
        if (await verifyPrivileges((user))) {
          print(user);
          _stateController.add(LoginState.SUCCESS);
        } else {
          print(user);
          FirebaseAuth.instance.signOut();
          _stateController.add(LoginState.FAIL);
        }
      } else {
        _stateController.add(LoginState.IDLE);
      }
    });
  }

  Stream<bool> get outSubmitValid =>
      Observable.combineLatest2(outEmail, outPass, (a, b) => true);

  void submit({String email, String pass}) {
    final email = _emailController.value;
    final pass = _passController.value;
    print(email);
    print(pass);

    _stateController.add(LoginState.LOADING);
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: pass)
        .catchError((e) {
      print(e);
      _stateController.add(LoginState.FAIL);
    });
  }

  Future<bool> signOut() async {
    await FirebaseAuth.instance.signOut();
    return true;
  }

  Future<bool> verifyPrivileges(FirebaseUser user) async {
    return await Firestore.instance
        .collection('companies')
        .document(user.uid)
        .get()
        .then((doc) {
      if (doc.data != null) {
        print('possue priviégio autorizados');
        return true;
      } else {
        print('NÃO priviégio autorizados');
        return false;
      }
    }).catchError((e) {
      print(e);
      return false;
    });
  }

  @override
  void dispose() {
    _emailController.close();
    _passController.close();
    _stateController.close();
    _subscription.cancel();
  }
}
