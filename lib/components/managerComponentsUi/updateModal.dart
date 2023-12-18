import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateModal extends StatefulWidget {
  final Future<void> Function(String, String, String)
      onSaveUpdatedCredentialToFirestore;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  UpdateModal({
    required this.onSaveUpdatedCredentialToFirestore,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateModalState createState() => _UpdateModalState();
}

class _UpdateModalState extends State<UpdateModal> {
  bool _isPasswordVisible = false;

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
          formTextField("Ingrese su usuario", Icons.person,
              widget.usernameController, false),
          formHeading("E-mail"),
          formTextField(
              "Ingrese su e-mail", Icons.email, widget.emailController, false),
          formHeading("Contraseña"),
          formTextFieldWithIcon(
            "Ingrese su contraseña",
            Icons.lock_outline,
            widget.passwordController,
            Icons.visibility,
            _isPasswordVisible,
            _togglePasswordVisibility,
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
                shadowColor: MaterialStatePropertyAll(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    side: BorderSide(color: Colors.blue),
                  ),
                ),
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () async {
                String username = widget.usernameController.text;
                String email = widget.emailController.text;
                String password = widget.passwordController.text;

                if (_validateFields(username, email, password)) {
                  await widget.onSaveUpdatedCredentialToFirestore(
                      username, email, password);

                  widget.usernameController.clear();
                  widget.emailController.clear();
                  widget.passwordController.clear();

                  Navigator.pop(context);
                }
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

  Widget formTextField(String hintText, IconData icon,
      TextEditingController controller, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo no puede estar vacío';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
            child: Icon(
              icon,
              color: Colors.blue,
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _togglePasswordVisibility();
                  },
                )
              : null,
          filled: true,
          contentPadding: const EdgeInsets.all(16),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
          fillColor: Color.fromARGB(255, 167, 25, 172).withOpacity(0.2),
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

  Widget formTextFieldWithIcon(
      String hintText,
      IconData icon,
      TextEditingController controller,
      IconData suffixIcon,
      bool isVisible,
      VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo no puede estar vacío';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
            child: Icon(
              icon,
              color: Colors.blue,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              suffixIcon,
              color: Colors.blue,
            ),
            onPressed: onPressed,
          ),
          filled: true,
          contentPadding: const EdgeInsets.all(16),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
          fillColor: Color.fromARGB(255, 167, 25, 172).withOpacity(0.2),
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

  bool _validateFields(String username, String email, String password) {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showToast("Todos los campos son obligatorios");
      return false;
    }

    if (!_isValidEmail(email)) {
      _showToast("Por favor, ingrese un correo electrónico válido");
      return false;
    }

    if (password.length < 8) {
      _showToast("La contraseña debe tener al menos 8 caracteres");
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(email);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
