import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modernlogintute/Model/password_model.dart';
import 'package:modernlogintute/components/managerComponentsUi/AddModal.dart';
import 'package:modernlogintute/components/managerComponentsUi/CategoryContainer.dart';
import 'package:modernlogintute/components/managerComponentsUi/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modernlogintute/pages/my_credentials.dart';

class HomePage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  String get userName => user?.displayName ?? "Usuario";

  // Sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> saveCredentialToFirestore(String username, String email,
      String password, String platformSite) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('credentials').add({
          'username': username,
          'email': email,
          'password': password,
          'usedRecently': false,
          'platformSite': platformSite,
        });
      }
    } catch (e) {
      ('Error al guardar la credencial: $e');
    }
  }

  void bottomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AddModal(
              onSaveCredentialToFirestore: (String website, String username,
                  String email, String password, String plaformSite) async {
                await saveCredentialToFirestore(
                    username, email, password, plaformSite);
                // Limpia los controladores después de enviar los datos
                websiteController.clear();
                usernameController.clear();
                emailController.clear();
                passwordController.clear();
              },
              websiteController: websiteController,
              usernameController: usernameController,
              emailController: emailController,
              passwordController: passwordController,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? "Usuario";

    const String assetName = 'assets/bell.svg';
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Credentials Vault'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          const AssetImage("assets/profile_pic.jpg"),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Hola, $userName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${user?.email ?? ""}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                onTap: () {
                  // Aquí puedes agregar la lógica para ir a la pantalla de configuración
                  Navigator.pop(context); // Cierra el Drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Cerrar Sesión'),
                onTap: () {
                  // Aquí puedes agregar la lógica para cerrar sesión
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context); // Cierra el Drawer
                },
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => bottomModal(context),
          backgroundColor: Constants.fabBackground,
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: SvgPicture.asset("assets/4square.svg"),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyCredentialsScreen(),
                      ),
                    );
                  },
                  child: SvgPicture.asset("assets/shield.svg"),
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
            child: Column(
              children: [
                profilePicAndBellIcon(assetName, screenHeight, userName),
                const SizedBox(height: 20),
                searchText("Busca tu credencial"),
                const SizedBox(height: 10),
                // CategoryBoxes(),
                const SizedBox(height: 10),
                HeadingText('Usado Recientemente'),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('credentials')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    var credentials = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Passwords(
                        platformSite: data['namePlatform'],
                        username: data['username'],
                        email: data['email'],
                        password: data['password'],
                        documentId: doc.id,
                        platformReference: data['platformReference'],
                        usedRecently: data['usedRecently'] ?? false,
                      );
                    }).toList();

                    var recentlyUsedCredentials = credentials
                        .where((credential) => credential.usedRecently);

                    return Column(
                      children: recentlyUsedCredentials
                          .map(
                              (credential) => PasswordTile(credential, context))
                          .toList(),
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

  Widget PasswordTile(Passwords password, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              LogoBox(password, context),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      password.username,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 22, 22, 22),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      password.email,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 39, 39, 39),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          GestureDetector(
            onTap: () {
              // Aquí puedes implementar la lógica de copiar al portapapeles
              // Puedes usar la biblioteca "fluttertoast" o implementar tu propia lógica
              Fluttertoast.showToast(
                msg: "Copiado al portapapeles",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: SvgPicture.asset(
              "assets/copy.svg",
              semanticsLabel: 'copy icon ',
              height: screenHeight * 0.030,
            ),
          ),
        ],
      ),
    );
  }

  Widget LogoBox(Passwords password, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    if (password.password.startsWith('http')) {
      return Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Constants.logoBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 0.5,
          child: Image.network(password.password),
        ),
      );
    } else {
      // Utiliza la imagen predeterminada si no hay una URL de imagen válida
      return Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Constants.logoBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 0.5,
          child: Image.network(
            "https://cdn-icons-png.flaticon.com/512/3324/3324737.png",
          ),
        ),
      );
    }
  }

  Widget HeadingText(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget CategoryBoxes() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       CategoryBox(
  //         outerColor: Constants.lightBlue,
  //         innerColor: Constants.darkBlue,
  //         logoAsset: "assets/codesandbox.svg",
  //       ),
  //       CategoryBox(
  //         outerColor: Constants.lightGreen,
  //         innerColor: Constants.darkGreen,
  //         logoAsset: "assets/compass.svg",
  //       ),
  //       CategoryBox(
  //         outerColor: Constants.lightRed,
  //         innerColor: Constants.darkRed,
  //         logoAsset: "assets/credit-card.svg",
  //       ),
  //     ],
  //   );
  // }

  Widget circleAvatarRound() {
    return const CircleAvatar(
      radius: 28,
      backgroundColor: Color.fromARGB(255, 213, 213, 213),
      child: CircleAvatar(
        radius: 26.5,
        backgroundColor: Color.fromARGB(255, 139, 236, 180),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/profile_pic.jpg"),
            radius: 25,
          ),
        ),
      ),
    );
  }

  Widget profilePicAndBellIcon(
      String assetName, double screenHeight, String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 35, 20.0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              circleAvatarRound(),
              const Padding(
                padding: EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola",
                      style: TextStyle(
                        color: Color.fromARGB(255, 22, 22, 22),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Que Tal?",
                      style: TextStyle(
                        color: Color.fromARGB(255, 39, 39, 39),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SvgPicture.asset(assetName,
              semanticsLabel: 'bell icon ', height: screenHeight * 0.035),
        ],
      ),
    );
  }

  Widget searchText(String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
            child: Icon(
              Icons.search,
              color: Constants.searchGrey,
            ),
          ),
          filled: true,
          contentPadding: const EdgeInsets.all(16),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Constants.searchGrey,
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
      ),
    );
  }
}
