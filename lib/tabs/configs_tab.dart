import 'package:agendei/blocs/login_bloc.dart';
import 'package:agendei/screens/login_screen.dart';
import 'package:agendei/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConfigsTab extends StatefulWidget {
  @override
  _ConfigsTabState createState() => _ConfigsTabState();
}

class _ConfigsTabState extends State<ConfigsTab> {
  final _loginBloc = LoginBloc();
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<DocumentSnapshot> snapshot;

  String uidCompany;

  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uidCompany = user.uid.toString();
    return uidCompany;
  }

  @override
  void initState() {
    super.initState();
    getUID().then((results) {
      setState(() {
        uidCompany = results;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: CustomAppBar(),
      body: FutureBuilder<DocumentSnapshot>(
          future: Firestore.instance
              .collection('companies')
              .document(uidCompany)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            return Container(
              color: Colors.grey[850],
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 10.0)),
                  RaisedButton(
                    color: Colors.blueAccent,
                    elevation: 0.0,
                    onPressed: () {
                      print('informacoes da empresa');
                      print(snapshot.data['name']);
                      print(uidCompany);

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                                uidCompany: uidCompany,
                                company: snapshot.data,
                              )));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.info,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 35.0),
                        ),
                        Text(
                          'Informações da empresa',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    elevation: 0.0,
                    onPressed: () {
                      print('relatorios');
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.receipt,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 35.0),
                        ),
                        Text(
                          'Relatórios',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    elevation: 0.0,
                    onPressed: () {
                      print('meios de pagamento');
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.payment,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 35.0),
                        ),
                        Text(
                          'Meios de pagamento',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    elevation: 0.0,
                    onPressed: () {
                      print('Reportar um bug');
//                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.bug_report,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 35.0),
                        ),
                        Text(
                          'Reportar um bug no app',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    elevation: 0.0,
                    onPressed: () {
                      print('sair do aplicativo');
                      _loginBloc.signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  LoginScreen()));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 35.0),
                        ),
                        Text(
                          'Sair do aplicativo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize => Size(double.infinity, 300);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(color: Colors.blueAccent, boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 0, offset: Offset(0, 0))
        ]),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                IconButton(
//                  icon: Icon(Icons.menu, color: Colors.white,),
//                  onPressed: () {
//                    print('entrou');
//                  },
//                ),

                Text(
                  "Visão geral",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

                IconButton(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  onPressed: () {
//                    _loginBloc.signOut();
//                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
                  },
                )
              ],
            ),
//
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage('google.com.br'),
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Nome da empresa",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
//                    Text("email", style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 15
//                    ),),
//
//                    Text("telefone", style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 15
//                    ),),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
//                    Text("Clientes", style: TextStyle(
//                        color: Colors.white
//                    ),),
                    Text(
                      "12",
                      style: TextStyle(fontSize: 26, color: Colors.white),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
//                    Text("Agendamentos", style: TextStyle(
//                        color: Colors.white
//                    ),),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    Text(
                      "8",
                      style: TextStyle(fontSize: 26, color: Colors.white),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
//                    Text("Routines", style: TextStyle(
//                        color: Colors.white
//                    ),),
                    Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    Text(
                      "4",
                      style: TextStyle(fontSize: 26, color: Colors.white),
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Column(
                  children: <Widget>[
//                    Text("Savings", style: TextStyle(
//                        color: Colors.white
//                    ),),
                    Icon(
                      Icons.list,
                      color: Colors.white,
                    ),
                    Text(
                      "20",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  ],
                ),
                SizedBox(
                  width: 32,
                ),
                Column(
                  children: <Widget>[
//                    Text("July Goals",
//                      style: TextStyle(
//                          color: Colors.white
//                      ),),
                    Icon(
                      Icons.attach_money,
                      color: Colors.white,
                    ),
                    Text("50K",
                        style: TextStyle(color: Colors.white, fontSize: 24))
                  ],
                ),
                SizedBox(
                  width: 16,
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(0, size.height - 35);
    p.lineTo(size.width, size.height - 35);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
