import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/my_button.dart';
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/components/square_tile.dart';
import 'package:modernlogintute/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // sign user in method

  void signUserIn() async {
    // Mostrar el diálogo de carga
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content:  Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Iniciando sesión...'),
            ],
          ),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Cerrar el diálogo de carga
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Cerrar el diálogo de carga
      Navigator.pop(context);

      //show error message
      showErrorMessage(e.code);
      // Puedes mostrar un cuadro de diálogo genérico para otros errores
    }
  }

// Wrong email message popup
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 96, 104, 97),
            title: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 253, 253),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/vault.jpg',
                  width: 100.0,
                  height: 100.0,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Bienvenido, Inicia Sesión',
                  style: TextStyle(
                    color: Color.fromARGB(255, 65, 62, 62),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                //email textfiel
                const SizedBox(height: 20),
                MyTextField(
                  controller: emailController,
                  hintText: 'E-mail',
                  obscureText: false,
                ),
                const SizedBox(height: 8),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color.fromARGB(255, 83, 83, 83)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MyButton(
                  text: "Sign In",
                  onTap: signUserIn,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Or continue with',
                      style: TextStyle(color: Color.fromARGB(255, 54, 54, 54)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      onTap: () => AuthService().signInWithGoogle(),
                      imagePath: 'assets/google.png'
                      ),
                      
                    const SizedBox(width: 12),
                    SquareTile(
                      onTap: (){},
                      imagePath: 'assets/apple.png'
                      )
                  ],
                ),
                const SizedBox(height: 40),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Eres nuevo?',
                      style: TextStyle(color: Color.fromARGB(255, 54, 54, 54)),
                    ),
                    const SizedBox(width: 4),
                     GestureDetector(
                      onTap: widget.onTap,
                       child: const Text(
                        'Registrate Ahora',
                        style: TextStyle(
                          color: Color.fromARGB(255, 55, 126, 64),
                          fontWeight: FontWeight.bold,
                        ),
                                           ),
                     ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
