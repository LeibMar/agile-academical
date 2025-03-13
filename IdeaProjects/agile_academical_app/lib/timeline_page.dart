import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_client.dart';

class TimeLinePage extends StatelessWidget {
  final String idUsuario;

  TimeLinePage({required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Linha do Tempo',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Timeline(idUsuario: idUsuario),
    );
  }
}

class Timeline extends StatefulWidget {
  final String idUsuario;

  Timeline({required this.idUsuario});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final TextEditingController _postController = TextEditingController();

  Future<void> _sendPost() async {
    if (_postController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('tbpostagem').add({
        'idUsuario': FirebaseFirestore.instance.doc('usuario/${widget.idUsuario}'),
        'textoPostagem': _postController.text,
        'dataPostagem': DateTime.now(),
      });

      _postController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Postagem enviada com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _postController,
            decoration: InputDecoration(
              labelText: 'Escreva sua postagem',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendPost,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tbpostagem').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final posts = snapshot.data!.docs;
              List<Widget> postWidgets = [];

              for (var post in posts) {
                final data = post.data() as Map<String, dynamic>?;
                if (data != null) {
                  final textoPostagem = data['textoPostagem'] ?? 'N/A';
                  final dataPostagem = data['dataPostagem']?.toDate().toString() ?? 'N/A';
                  final DocumentReference? idUsuarioRef = data['idUsuario'] as DocumentReference?;

                  postWidgets.add(FutureBuilder<DocumentSnapshot>(
                    future: idUsuarioRef?.get(),

                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final String nomeUsuario = userSnapshot.data?.get('nome') ?? 'Nome não encontrado';
                      final String idUsuario = userSnapshot.data?.id ?? 'ID não encontrado';
                      return UserWidget(
                        idUsuario: idUsuario,
                        nomeUsuario : nomeUsuario,
                        textoPostagem: textoPostagem,
                        dataPostagem: dataPostagem,
                      );
                    },
                  ));
                }
              }

              return Align(
                alignment: Alignment.center,
                child: Container(
                  margin: currentHeight < 915
                      ? EdgeInsets.only(bottom: 200)
                      : EdgeInsets.only(bottom: 400),
                  padding: EdgeInsets.all(16.0),
                  constraints: BoxConstraints(
                    maxWidth: currentWidth < 600 ? 300 : 600,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.blue,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: postWidgets,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class UserWidget extends StatelessWidget {
  final String idUsuario;
  final String nomeUsuario;
  final String textoPostagem;
  final String dataPostagem;

  UserWidget({
    required this.idUsuario,
    required this.nomeUsuario,
    required this.textoPostagem,
    required this.dataPostagem,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue,
      child: ListTile(
        title: Text(
          'Usuário: $nomeUsuario',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '$textoPostagem - postado em $dataPostagem',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
