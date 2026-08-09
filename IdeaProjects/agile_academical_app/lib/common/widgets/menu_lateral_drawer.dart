import 'package:agile_academical_app/timeline_page.dart';
import 'package:agile_academical_app/user_list.dart';
import 'package:flutter/material.dart';
import '../../user_list.dart';
import '../../cadastro_etapa.dart';

class CustomDrawer extends StatelessWidget {
  final String currentUserId;

  const CustomDrawer({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Linha do Tempo'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Timeline(idUsuario: currentUserId,)),
              );

            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_on),
            title: const Text('Daily'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Timeline(idUsuario: currentUserId,)),
              );

            },
          ),
          ListTile(
            leading: const Icon(Icons.account_tree_outlined ),
            title: const Text('Etapas'),
            onTap: () {
              //Navigator.pushNamed(context, '/cadastro_etapa');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroEtapa(idUsuario: currentUserId,)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.moving_sharp),
            title: const Text('Progresso'),
            onTap: () {
              //Navigator.pushNamed(context, '/cadastro_etapa');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroEtapa(idUsuario: currentUserId,)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.attachment_rounded),
            title: const Text('Arquivos'),
            onTap: () {
              //Navigator.pushNamed(context, '/cadastro_etapa');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroEtapa(idUsuario: currentUserId,)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('Grupos'),
            onTap: () {
              //Navigator.pushNamed(context, '/cadastro_etapa');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserListPage(idUsuario: currentUserId,)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
