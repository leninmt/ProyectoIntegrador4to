import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference credentialCollection =
      FirebaseFirestore.instance.collection('credentials');
  Future<void> addCredential(String username, String email, String password,
      String platformReference, bool usedRecently) async {
    try {
      // Obtén el nombre de la plataforma desde la referencia de la plataforma
      DocumentSnapshot platformSnapshot =
          await _firestore.collection('platforms').doc(platformReference).get();
      String platformName = platformSnapshot['namePlatform'] as String;

      // Agrega la credencial a la colección 'credentials' y guarda el nombre de la plataforma
      await credentialCollection.add({
        'username': username,
        'email': email,
        'password': password,
        'platformReference': platformReference,
        'usedRecently': usedRecently,
        'namePlatform': platformName, // Asegúrate de incluir este campo
      });
    } catch (e) {
      print("Error adding credential: $e");
      // Maneja el error según tus necesidades
    }
  }

  Future<void> deleteCredential(String documentId) async {
    await credentialCollection.doc(documentId).delete();
  }

  Future<void> updateCredential(String documentId, String username,
      String email, String password, bool usedRecently) async {
    await credentialCollection.doc(documentId).update({
      'username': username,
      'email': email,
      'password': password,
      'usedRecently': usedRecently,
    });
  }

  Future<List<String>> getPlatforms() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('platforms').get();
      List<String> platforms = querySnapshot.docs
          .map((doc) => doc['namePlatform'] as String)
          .toList();
      return platforms;
    } catch (e) {
      print("Error getting platforms: $e");
      return [];
    }
  }

Future<String> getPlatformSite(String platformName) async {
    try {
      // Acceder al documento correspondiente en la colección "platforms"
      var platformDoc = await _firestore.collection('platforms').doc(platformName).get();

      // Verificar si el documento existe y contiene el campo "namePlatforms"
      if (platformDoc.exists) {
        var platformSite = platformDoc['namePlatforms'];
        return platformSite;
      } else {
        // Manejar el caso en que el documento no existe
        return 'No se encontró el sitio asociado';
      }
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la obtención de datos
      print('Error al obtener el sitio de la plataforma: $e');
      return 'Error obteniendo el sitio de la plataforma';
    }
  }



  Future<void> addPlatform(String platformName) async {
    try {
      await _firestore.collection('platforms').add({
        'namePlatform': platformName,
        // Puedes agregar más campos según tus necesidades
      });
    } catch (e) {
      print('Error al agregar la plataforma: $e');
      // Maneja el error según tus necesidades
    }
  }

  Future<void> saveCredentialToFirestore(String username, String email,
      String password, String namePlatform) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('credentials').add({
          'username': username,
          'email': email,
          'password': password,
          'usedRecently': false,
          'namePlatform': namePlatform, // Agrega la plataforma seleccionada
        });
      }
    } catch (e) {
      print('Error al guardar la credencial: $e');
    }
  }
}
