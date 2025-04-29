import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'common/styles/colors.dart'; // Atenção no import atualizado
import 'cadastro_etapa.dart';
import 'common/widgets/menu_lateral_drawer.dart';

class TimeLinePage extends StatelessWidget {
  final String idUsuario;

  const TimeLinePage({required this.idUsuario, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Timeline(idUsuario: idUsuario),
    );
  }
}

class Timeline extends StatefulWidget {
  final String idUsuario;

  const Timeline({required this.idUsuario, super.key});

  @override
  State<Timeline> createState() => _TimelineState();
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
        const SnackBar(content: Text('Postagem enviada com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    return Scaffold (
      appBar: AppBar(
        title: const Text('Linha do Tempo'),
        centerTitle: true,
      ),
      drawer: CustomDrawer(currentUserId: widget.idUsuario),

      body: Column(
      children: [
        Padding(

          padding: const EdgeInsets.all(16.0),

          child: TextField(
            controller: _postController,
            decoration: InputDecoration(
              labelText: 'Escreva sua postagem',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: _sendPost,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroEtapa(idUsuario: widget.idUsuario,)),
              );
            },
            child: Text("Lista de Etapas do Projeto"),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tbpostagem').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final posts = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final data = posts[index].data() as Map<String, dynamic>?;
                  if (data == null) return const SizedBox();

                  final textoPostagem = data['textoPostagem'] ?? 'N/A';
                  final dataPostagem = data['dataPostagem']?.toDate().toString() ?? 'N/A';
                  final DocumentReference? idUsuarioRef = data['idUsuario'] as DocumentReference?;

                  return FutureBuilder<DocumentSnapshot>(
                    future: idUsuarioRef?.get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final nomeUsuario = userSnapshot.data?.get('nome') ?? 'Nome não encontrado';
                      return Card(
                        color: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            nomeUsuario,
                            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '$textoPostagem\n\n$dataPostagem',
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    ), );
  }
}
