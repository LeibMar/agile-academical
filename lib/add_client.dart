import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserAddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title:  Align (
          alignment: Alignment.center,

          child: Text('Adicionar Cliente', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
        ),


      ),
      body: UserAdd(),
    );
  }
}

class UserAdd extends StatefulWidget {
  @override
  _UserAddState createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String nome = _nameController.text;
      final String email = _emailController.text;
      final int idade = int.parse(_ageController.text);

      try {
        await FirebaseFirestore.instance.collection('tbcliente').add({
          'cliente': nome,
          'email': email,
          'idade': idade,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cliente adicionado com sucesso!')));
        _nameController.clear();
        _emailController.clear();
        _ageController.clear();
        Get.toNamed('/user_list');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao adicionar cliente: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    return  Align(
      alignment: Alignment.center,
      child:  Container(



        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.blue,

        ),


        margin: currentHeight < 300 ? const EdgeInsets.only(bottom: 150) : const EdgeInsets.only(bottom: 250) ,
        width: currentWidth < 400 ?  300 :  600,

        child: Padding (
          padding: EdgeInsets.all(16.0),

          child: Form(

            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nome' ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return ' Insira um email válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Idade'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira a idade';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Insira um número válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Adicionar Cliente'),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


