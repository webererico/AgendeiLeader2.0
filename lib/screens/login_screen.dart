import 'package:agendei/blocs/login_bloc.dart';
import 'package:agendei/screens/home_screen.dart';
import 'package:agendei/screens/newProfile_screen.dart';
import 'package:agendei/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';




class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final _loginBloc = LoginBloc();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String email;



//
//  _launchURL() async {
//    const url = 'https://flutter.dev';
//    if (await canLaunch(url)) {
//      await launch(url);
//    } else {
//      throw 'Could not launch $url';
//    }
//  }
  void resetPassword() async{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  @override
  void initState() {
    super.initState();
    _loginBloc.outState.listen((state) {
      switch (state) {
        case LoginState.SUCCESS:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
          break;
        case LoginState.FAIL:
          showDialog(

            context: context,
            builder: (context) => AlertDialog(
              title: Text('Erro'),
              content: Text('Você não é administrador'),
              actions: <Widget>[
                FlatButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text('Voltar'),
                ),
              ],
            ),
          );
          break;
        case LoginState.LOADING:
        case LoginState.IDLE:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
//    const String toLaunch = 'https://youtube.com';
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[850],
      body: StreamBuilder<LoginState>(
          stream: _loginBloc.outState,
          initialData: LoginState.LOADING,
          builder: (context, snapshot) {

            switch (snapshot.data) {
              case LoginState.LOADING:
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                  ),
                );
              case LoginState.FAIL:
              case LoginState.SUCCESS:
              case LoginState.IDLE:
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: Colors.blueAccent,
                              size: 140,
                            ),
                            Center(
                              child: Text(
                                'Agendei Leader',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 32.0),
                              ),
                            ),
                            InputField(
                              icon: Icons.email,
                              hint: 'E-mail',
                              obscure: false,
                              stream: _loginBloc.outEmail,
                              onChanged: (value){
                                _loginBloc.changeEmail(value);
                                if(value == null){
                                  setState(() {
                                    email = null;
                                  });
                                }else{
                                  setState(() {
                                    email = value;
                                  });
                                }

                              }

                            ),
                            InputField(
                              icon: Icons.lock,
                              hint: 'Senha',
                              obscure: true,
                              stream: _loginBloc.outPass,
                              onChanged: _loginBloc.changePass,
                            ),
                            SizedBox(
                              height: 40.0,
                            ),
                            StreamBuilder<bool>(
                                stream: _loginBloc.outSubmitValid,
                                builder: (context, snapshot) {
                                  return SizedBox(
                                    height: 40.0,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(35.0)),
                                      color: Colors.blueAccent,
                                      elevation: 10,
                                      child: Text('Entrar'),
                                      textColor: Colors.white,
                                      onPressed: snapshot.hasData
                                          ? _loginBloc.submit
                                          : null,
                                      disabledColor:
                                      Colors.lightBlueAccent.withAlpha(140),
                                    ),
                                  );
                                }),
                            FlatButton(
                              onPressed: () {
                                if (email.toString().isEmpty) {
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'O campo e-mail está vazio ou é inválido. Por favor, informe somente e-mail para recuperar sua senha'),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                } else {
                                  resetPassword();
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Confira seu e-mail. Enviamos um e-mail de recuperação de senha para você. :D'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "Esqueci minha senha",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            SizedBox(
                              height: 40.0,
                            ),
                            SizedBox(
                              height: 40.0,
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(35.0)),
                                  color: Colors.green,
                                  child: Text('Cadastrar minha empresa'),
                                  textColor: Colors.white,
                                  onPressed: (){
                                    return Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=> NewProfile()));
                                  }
                                  ),
                            ),
                            SizedBox(
                              height: 40.0,
                            ),
                            SizedBox(
                              height: 40.0,
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(35.0)),
                                  color: Colors.white,
                                  child: Text(
                                    'Como funciona ?',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    return showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Quer saber como o Agendei funciona?'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text('Somos a nova plataforma 100% digital de agendamentos multiserviços, entregando praticidade e qualidade na realizacão de agendamentos e controle. (Sério, controle sobre todos dados).', textAlign: TextAlign.justify,),
                                                Text('Para conhecer quais nossas vantagens e possibilidades para seu negócio acesse nosso site: www.agendei.com.br e conheça essa revolução. :D', textAlign: TextAlign.justify),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('Voltar'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('A revolução é aqui. VISITAR SITE!'),
//                                              onPressed: _launchURL,
                                              onPressed: (){},

                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              default:
                return Container();
            }
          }),
    );
  }




  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}
