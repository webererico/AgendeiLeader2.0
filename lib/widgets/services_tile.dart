
import 'package:agendei/screens/service_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesTile extends StatelessWidget {
  final DocumentSnapshot services;
  final uidCompany;

  ServicesTile(this.services, this.uidCompany);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 4,
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            services.data['name'],
            style:
                TextStyle(color: Colors.grey[850], fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            services.data['description'].toString(),
            style:
                TextStyle(color: Colors.grey[850], fontWeight: FontWeight.w500),
          ),
          children: <Widget>[
            ListTile(
              title: Text('R\$' + ' ' + '${services.data['price']}'),
              trailing: Text('${services.data['duration']}' 'min'),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ServiceScreen(
                                uidService: services.documentID,
                                service: services,
                                uidCompany: uidCompany,
                              )));
                    },
                    icon: Icon(Icons.settings),
                    label: Text('Alterar')),
                RaisedButton.icon(
                  onPressed: () {

                  },
                  icon: Icon(
                    Icons.history,
                    color: Colors.white,
                  ),
                  label: Text('Histórico'),
                  color: Color.fromARGB(255, 15, 76, 129),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
