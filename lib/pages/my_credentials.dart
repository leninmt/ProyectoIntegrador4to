import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modernlogintute/Model/password_model.dart';
import 'package:modernlogintute/components/managerComponentsUi/updateModal.dart';

class MyCredentialsScreen extends StatefulWidget {
  @override
  _MyCredentialsScreenState createState() => _MyCredentialsScreenState();
}

class _MyCredentialsScreenState extends State<MyCredentialsScreen> {
  TextEditingController searchController = TextEditingController();

  Widget searchText(String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
            child: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
          filled: true,
          contentPadding: const EdgeInsets.all(16),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w500,
          ),
          fillColor: Color.fromARGB(255, 112, 199, 127),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        style: TextStyle(),
        onChanged: (value) {
          setState(() {}); // Disparar el rebuild al cambiar el texto
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Credentials'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('credentials').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var credentials = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Passwords(
                namePlatform: data['namePlatform'],
                username: data['username'],
                email: data['email'],
                password: data['password'],
                documentId: doc.id,
                platformReference: data['platformReference'],
                usedRecently: data['usedRecently'] ?? false, // Nueva línea
            );
          }).toList();

          // Filtra los resultados basados en la búsqueda por email o username
          var filteredCredentials = credentials.where((credential) {
            return credential.email
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                credential.username
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: searchText('Busca tu credencial'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCredentials.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final credential = filteredCredentials[index];

                    return Dismissible(
                      key: Key(credential.documentId),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) async {
                        await FirebaseFirestore.instance
                            .collection('credentials')
                            .doc(credential.documentId)
                            .delete();
                      },
                      child: ListTile(
                        title: Text(credential.username),
                        subtitle: Text(credential.email),
                        trailing: IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            _copyToClipboard(credential);
                          },
                        ),
                        onTap: () {
                          _showUpdateModal(context, credential);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateModal(BuildContext context, Passwords credential) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        TextEditingController usernameController =
            TextEditingController(text: credential.username);
        TextEditingController emailController =
            TextEditingController(text: credential.email);
        TextEditingController passwordController =
            TextEditingController(text: credential.password);

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: UpdateModal(
              onSaveUpdatedCredentialToFirestore: (String newUsername,
                  String newEmail, String newPassword) async {
                String docId = credential.documentId;
                String username = newUsername;
                String email = newEmail;
                String password = newPassword;

                try {
                  await FirebaseFirestore.instance
                      .collection('credentials')
                      .doc(docId)
                      .update({
                    'username': username,
                    'email': email,
                    'password': password,
                    'usedRecently': true, // Marcar como utilizado recientemente
                  });

                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error al actualizar: $e');
                }
              },
              usernameController: usernameController,
              emailController: emailController,
              passwordController: passwordController,
            ),
          ),
        );
      },
    );
  }

  void _copyToClipboard(Passwords credential) {
    final String dataToCopy = 'Username: ${credential.username}\nEmail: ${credential.email}\nPassword: ${credential.password}';
    FlutterClipboard.copy(dataToCopy).then((value) async {
      // Marcar como utilizado recientemente en Firestore
      await FirebaseFirestore.instance
          .collection('credentials')
          .doc(credential.documentId)
          .update({'usedRecently': true});

      Fluttertoast.showToast(msg: 'Datos copiados al portapapeles');
    });
  }
}