import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_client.dart';
import 'timeline_page.dart';
import 'login.dart';
import 'common/widgets/menu_lateral_drawer.dart';

import 'package:get/get.dart';


class UserListPage extends StatelessWidget {
  final String idUsuario;
  UserListPage({required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    return Scaffold(

        appBar: AppBar(
          title: Align (
            alignment: Alignment.center,

            child: Text('Lista de Clientes', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
          ),

        ),
       drawer: CustomDrawer(currentUserId: idUsuario),
        body: UserList(),


    );
  }
}

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tbcliente').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data!.docs;
        List<UserWidget> userWidgets = [];
        for (var user in users) {
          final data = user.data() as Map<String, dynamic>?;

          final cliente = (data != null && data['cliente'] != null) ? data['cliente'] as String : 'N/A';
          final email = (data != null && data['email'] != null) ? data['email'] as String : 'N/A';
          final idade = (data != null && data['idade'] != null) ? data['idade'].toString() : 'N/A';

          final userWidget = UserWidget(
            cliente: cliente,
            email: email,
            idade: idade,
          );
          userWidgets.add(userWidget);
        }
        return Align(
            alignment: Alignment.center,

            child: Container(
              margin: currentHeight < 915 ? EdgeInsets.only( bottom: 200) : EdgeInsets.only( bottom: 400),


              padding: EdgeInsets.all(16.0),
              constraints: BoxConstraints(
                maxWidth: currentWidth < 600 ? 300 : 600 ,


              ),
              decoration: BoxDecoration (
                borderRadius: BorderRadius.circular(5),
                color: Colors.blue,),


              child: ListView (
                shrinkWrap: true,
                children: userWidgets,
              ),
            )
        );
      },

    );

  }
}

class UserWidget extends StatelessWidget {
  final String cliente;
  final String email;
  final String idade;

  UserWidget({required this.cliente, required this.email, required this.idade});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(cliente, style: TextStyle(color: Colors.white),),
      subtitle: Text('$email - $idade anos', style: TextStyle(color: Colors.white)),

    );




  }

}

class NavAddUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.lightBlue[50],
      width:  currentWidth < 600 ? 200 : 300 ,
      margin: currentHeight < 300 ? const EdgeInsets.only(bottom: 150) : const EdgeInsets.only(bottom: 250) ,
      child: Align (
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration (
            borderRadius: BorderRadius.circular(5),
            color: Colors.blue,),
          child: Column(
              children:  [ TextButton(

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserAddPage()),
                  );
                },
                child: Text(
                  "Adicionar cliente", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),


                TextButton(

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Login", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ), ]
          ),
        ),
      ),
    );
  }
}

