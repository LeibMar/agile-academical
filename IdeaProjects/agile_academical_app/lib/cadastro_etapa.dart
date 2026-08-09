import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'common/styles/colors.dart';
import 'common/widgets/menu_lateral_drawer.dart';

class CadastroEtapaPage extends StatelessWidget {
  final String idUsuario;

  CadastroEtapaPage({required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Etapas',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      drawer: CustomDrawer(currentUserId: idUsuario),
      body: CadastroEtapa(idUsuario: idUsuario),
    );
  }
}


class CadastroEtapa extends StatefulWidget {
  final String idUsuario;

  CadastroEtapa({required this.idUsuario});

  @override
  _CadastroEtapaState createState() => _CadastroEtapaState();
}

class _CadastroEtapaState extends State<CadastroEtapa> {
  final TextEditingController _nomeEtapaController = TextEditingController();
  final TextEditingController _assuntoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  final GlobalKey<FlutterMentionsState> _responsavelKey = GlobalKey<FlutterMentionsState>();
  final GlobalKey<FlutterMentionsState> _observadorKey = GlobalKey<FlutterMentionsState>();
  final GlobalKey<FlutterMentionsState> _subEtapaKey = GlobalKey<FlutterMentionsState>();

  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> etapas = [];

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
    carregarEtapas();
  }

  Future<void> carregarUsuarios() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('usuario').get();
    setState(() {
      usuarios = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'display': "@${doc['username']}",
          'full_name': doc['nome'],
        };
      }).toList();
    });
  }

  Future<void> carregarEtapas() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('etapa').get();
    setState(() {
      etapas = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'display': "#${doc['nomeEtapa']}",
          'full_name': doc['nomeEtapa'],
        };
      }).toList();
    });
  }

  Future<void> _sendPost() async {
    if (_nomeEtapaController.text.isNotEmpty) {
      List<String> responsaveis = _extractMentions(_responsavelKey);
      List<String> observadores = _extractMentions(_observadorKey);
      List<String> subEtapas = _extractMentions(_subEtapaKey);

      await FirebaseFirestore.instance.collection('etapa').add({
        'nomeEtapa': _nomeEtapaController.text,
        'criadorEtapa': FirebaseFirestore.instance.doc('usuario/${widget.idUsuario}'),
        'responsavelEtapa': responsaveis.map((id) => FirebaseFirestore.instance.doc('usuario/$id')).toList(),
        'observadorEtapa': observadores.map((id) => FirebaseFirestore.instance.doc('usuario/$id')).toList(),
        'subEtapas': subEtapas.map((id) => FirebaseFirestore.instance.doc('etapa/$id')).toList(),
        'assuntoEtapa': _assuntoController.text,
        'descricaoEtapa': _descricaoController.text,
        'etapaFinalizada': true,
        'dataPostagem': DateTime.now(),
      });

      _nomeEtapaController.clear();
      _assuntoController.clear();
      _descricaoController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Etapa cadastrada com sucesso!')),
      );
    }
  }

  List<String> _extractMentions(GlobalKey<FlutterMentionsState> key) {
    String text = key.currentState!.controller!.text;
    List<String> ids = [];

    for (var usuario in usuarios) {
      if (text.contains(usuario['display'])) {
        ids.add(usuario['id']);
      }
    }

    for (var etapa in etapas) {
      if (text.contains(etapa['display'])) {
        ids.add(etapa['id']);
      }
    }

    return ids;
  }

  Future<List<String>> _fetchResponsaveisNomes(dynamic responsavelRefs) async {
    List<String> nomes = [];

    if (responsavelRefs == null) return [];

    if (responsavelRefs is DocumentReference) {
      // Caso seja um único DocumentReference
      DocumentSnapshot doc = await responsavelRefs.get();
      if (doc.exists) {
        nomes.add(doc.get('nome') ?? 'Nome não encontrado');
      }
    } else if (responsavelRefs is List) {
      // Caso seja uma lista de DocumentReference
      for (var ref in responsavelRefs) {
        if (ref is DocumentReference) {
          DocumentSnapshot doc = await ref.get();
          if (doc.exists) {
            nomes.add(doc.get('nome') ?? 'Nome não encontrado');
          }
        }
      }
    }

    return nomes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etapas'),
        centerTitle: true,
      ),
      drawer: CustomDrawer(currentUserId: widget.idUsuario),
      body: Portal(
        child: SingleChildScrollView( // Garantir que não haja overflow
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeEtapaController,
                  decoration: InputDecoration(labelText: 'Nome da etapa'),
                ),
                SizedBox(height: 12),
                _buildMentionField("Responsáveis", _responsavelKey, usuarios),
                SizedBox(height: 12),
                _buildMentionField("Observadores", _observadorKey, usuarios),
                SizedBox(height: 12),
                _buildMentionField("Subetapas", _subEtapaKey, etapas),
                SizedBox(height: 12),
                TextField(
                  controller: _assuntoController,
                  decoration: InputDecoration(labelText: 'Assunto da etapa'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'Descrição da etapa'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _sendPost,
                  child: Text("Cadastrar Etapa"),
                ),
                SizedBox(height: 24),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('etapa').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final posts = snapshot.data!.docs;
                    List<Widget> postWidgets = [];

                    for (var post in posts) {
                      final data = post.data() as Map<String, dynamic>?;

                      if (data != null) {
                        final String nomeEtapa = data['nomeEtapa'] ?? 'N/A';
                        final String assuntoEtapa = data['assuntoEtapa'] ?? 'N/A';
                        final String descricaoEtapa = data['descricaoEtapa'] ?? 'N/A';
                        final bool etapaFinalizada = data['etapaFinalizada'] ?? false;
                        final DocumentReference? idUsuarioRef = data['criadorEtapa'] as DocumentReference?;
                        final dynamic responsavelEtapa = data['responsavelEtapa'];

                        postWidgets.add(FutureBuilder<DocumentSnapshot>(
                          future: idUsuarioRef?.get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final String nomeUsuario = userSnapshot.data?.get('nome') ?? 'Nome não encontrado';

                            return FutureBuilder<List<String>>(
                              future: _fetchResponsaveisNomes(responsavelEtapa),
                              builder: (context, responsavelSnapshot) {
                                if (responsavelSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                final String responsaveis = responsavelSnapshot.data?.join(', ') ?? 'Nenhum responsável';

                                return UserWidget(
                                  criadorEtapa: nomeUsuario,
                                  nomeEtapa: nomeEtapa,
                                  assuntoEtapa: assuntoEtapa,
                                  descricaoEtapa: descricaoEtapa,
                                  etapaFinalizada: etapaFinalizada,
                                  responsavelEtapa: responsaveis,
                                );
                              },
                            );
                          },
                        ));
                      }
                    }

                    //return Column(children: postWidgets);
                    return GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: postWidgets,
                    );

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}



Widget _buildMentionField(String hint, GlobalKey<FlutterMentionsState> key, List<Map<String, dynamic>> data) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: FlutterMentions(
      key: key,
      suggestionPosition: SuggestionPosition.Top,
      mentions: [
        Mention(
          trigger: "@",
          data: data,
          style: TextStyle(color: Colors.blue),
          matchAll: false,
          suggestionBuilder: (data) {
            return ListTile(
              title: Text(data['full_name']),
              subtitle: Text(data['display']),
            );
          },
        ),
      ],
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    ),
  );
}

class UserWidget extends StatefulWidget {
  final String criadorEtapa;
  final String nomeEtapa;
  final String assuntoEtapa;
  final String descricaoEtapa;
  final String responsavelEtapa;
  final bool etapaFinalizada;

  UserWidget({
    required this.criadorEtapa,
    required this.nomeEtapa,
    required this.assuntoEtapa,
    required this.descricaoEtapa,
    required this.etapaFinalizada,
    required this.responsavelEtapa,
  });

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: _isHovered
              ? [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]
              : [BoxShadow(color: Colors.black12, blurRadius: 4)],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Etapa: ${widget.nomeEtapa}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('Criador: ${widget.criadorEtapa}'),
            Text('Responsável: ${widget.responsavelEtapa}'),
            Text('Assunto: ${widget.assuntoEtapa}'),
            Text('Descrição: ${widget.descricaoEtapa}'),
            if (widget.etapaFinalizada)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Chip(
                  label: Text('Finalizada', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
