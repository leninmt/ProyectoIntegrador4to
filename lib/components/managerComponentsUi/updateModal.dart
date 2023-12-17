// updateModal.dart

import 'package:flutter/material.dart';
import 'constants.dart';

class UpdateModal extends StatelessWidget {
  final Future<void> Function(String, String, String)
      onSaveUpdatedCredentialToFirestore;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  //final TextEditingController websiteController;

  UpdateModal({
    required this.onSaveUpdatedCredentialToFirestore,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    //required this.websiteController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: screenWidth * 0.4,
              height: 5,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 216, 202, 202),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 10,
          ),
          formHeading("Usuario"),
          formTextField("Ingrese su usuaio", Icons.person, usernameController),
          formHeading("E-mail"),
          formTextField("Ingrese su e-mail", Icons.email, emailController),
          formHeading("Constraseña"),
          formTextField(
            "Ingrese su contraseña",
            Icons.lock_outline,
            passwordController,
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            height: screenHeight * 0.065,
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
                String username = usernameController.text;
                String email = emailController.text;
                String password = passwordController.text;

                await onSaveUpdatedCredentialToFirestore(
                    username, email, password);

                usernameController.clear();
                emailController.clear();
                passwordController.clear();

                Navigator.pop(context); // Cierra el modal después de actualizar
              },
              child: const Text(
                "Guardar Cambios",
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
        padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
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
}
