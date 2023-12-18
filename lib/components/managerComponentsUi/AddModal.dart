import 'package:flutter/material.dart';
import 'package:modernlogintute/services/firebase_service.dart';
import 'constants.dart';

class AddModal extends StatefulWidget {
  final Future<void> Function(String, String, String, String, String)
      onSaveCredentialToFirestore;
  final TextEditingController websiteController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  AddModal({
    required this.onSaveCredentialToFirestore,
    required this.websiteController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    Key? key,
  }) : super(key: key);

  @override
  _AddModalState createState() => _AddModalState();
}

class _AddModalState extends State<AddModal> {
  final FirebaseService _firebaseService = FirebaseService();
  List<String> platformList = [];

  final TextEditingController websiteController = TextEditingController();
  String selectedPlatform = '';

  @override
  void initState() {
    super.initState();
    _loadPlatforms();
  }

  Future<void> _loadPlatforms() async {
    List<String> platforms = await _firebaseService.getPlatforms();
    setState(() {
      platformList = platforms;
    });
  }

  void _showAddWebsiteModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Sitio Web'),
          content: TextField(
            controller: websiteController,
            decoration: const InputDecoration(hintText: 'Ingrese el sitio web'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Agregar la nueva plataforma a la colección "platforms" en Firebase
                await _firebaseService.addPlatform(websiteController.text);

                setState(() {
                  platformList.add(websiteController.text);
                  selectedPlatform = websiteController.text;
                });

                websiteController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
      child: Column(
        children: [
          const SizedBox(
            height: 2,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: screenWidth * 0.4,
              height: 5,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 156, 156, 156),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          searchText("Search for a website or app"),
          const SizedBox(
            height: 10,
          ),
          websiteContainer(),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 25, 20, 25),
            child: Text(
              selectedPlatform,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Column(
            children: [
              formHeading("Usuario"),
              formTextField("Ingrese su usuario", Icons.person,
                  widget.usernameController),
              formHeading("E-mail"),
              formTextField(
                  "Ingrese su e-mail", Icons.email, widget.emailController),
              formHeading("Contraseña"),
              formTextField("Ingrese su contraseña", Icons.lock_outline,
                  widget.passwordController),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            height: 60,
            width: screenWidth * 0.7,
            child: ElevatedButton(
              style: ButtonStyle(
                elevation: const MaterialStatePropertyAll(5),
                shadowColor:
                    MaterialStatePropertyAll(Constants.buttonBackground),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    side: BorderSide(color: Constants.buttonBackground),
                  ),
                ),
                backgroundColor:
                    MaterialStatePropertyAll(Constants.buttonBackground),
              ),
              onPressed: () async {
                String website = selectedPlatform;
                String username = widget.usernameController.text;
                String email = widget.emailController.text;
                String password = widget.passwordController.text;

                // Aquí se usa el método onSaveCredentialToFirestore con un parámetro adicional para la plataforma seleccionada
                await widget.onSaveCredentialToFirestore(
                    website, username, email, password, selectedPlatform);

                widget.usernameController.clear();
                widget.emailController.clear();
                widget.passwordController.clear();
                widget.websiteController.clear();

                Navigator.pop(context);
              },
              child: const Text(
                "Guardar",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget formTextField(
      String hintText, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
            child: Icon(
              icon,
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
          fillColor: const Color.fromARGB(181, 57, 146, 94),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        style: const TextStyle(),
      ),
    );
  }

  Widget formHeading(String text) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 5, 5, 5),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget websiteContainer() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        InkWell(
          onTap: () {
            _showAddWebsiteModal(context);
          },
          child: Container(
            height: 55,
            width: 120,
            decoration: BoxDecoration(
              color: Constants.logoBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "Add",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            height: 60,
            width: screenWidth * 0.7,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: platformList.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  setState(() {
                    selectedPlatform = platformList[index];
                  });
                },
                child: websiteBlock(platformList[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget websiteBlock(String websiteString) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6.0, 3, 6, 3),
      child: Container(
        height: 50,
        width: 120,
        decoration: BoxDecoration(
          color: Constants.logoBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                websiteString,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
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
          fillColor: Color.fromARGB(255, 121, 197, 216),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        style: const TextStyle(),
      ),
    );
  }
}
