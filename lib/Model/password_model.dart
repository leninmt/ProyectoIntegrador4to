import 'dart:convert';

class Passwords {
  final String? platformSite;
  final String username;
  final String email;
  final String password;
  final String documentId;
  final String? platformReference;
  bool usedRecently; // Agregamos este campo

  Passwords({
    required this.platformSite,
    required this.username,
    required this.email,
    required this.password,
    required this.documentId,
    required this.platformReference,
    this.usedRecently = false, // Inicializamos como falso
  });

  Passwords copyWith({
    String? namePlatform,
    String? username,
    String? email,
    String? password,
    bool? usedRecently, // Agregamos este parámetro
  }) {
    return Passwords(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      documentId: this.documentId,
      platformSite: namePlatform ?? this.platformSite,
      platformReference: this.platformReference,
      usedRecently:
          usedRecently ?? this.usedRecently, // Aseguramos copiar el campo
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'platformSite': platformSite,
      'username': username,
      'email': email,
      'password': password,
      'documentId': documentId,
      'platformReference': platformReference,
      'usedRecently': usedRecently, // Agregamos este campo
    };
  }

  factory Passwords.fromMap(Map<String, dynamic> map) {
    return Passwords(
      platformSite: map["platformSite"] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      documentId: map['documentId'] as String,
      platformReference: map['platformReference'] as String,
      usedRecently: map['usedRecently'] as bool? ?? false, // Manejar nulo
    );
  }

  String toJson() => json.encode(toMap());

  factory Passwords.fromJson(String source) =>
      Passwords.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Passwords(platformSite: $platformSite, username: $username, email: $email, password: $password, documentId: $documentId, platformReference: $platformReference, usedRecently: $usedRecently)';

  @override
  bool operator ==(covariant Passwords other) {
    if (identical(this, other)) return true;

    return other.platformSite == platformSite &&
        other.username == username &&
        other.email == email &&
        other.password == password &&
        other.documentId == documentId &&
        other.platformReference == platformReference &&
        other.usedRecently ==
            usedRecently; // Comparar también el campo usado recientemente
  }

  @override
  int get hashCode =>
      platformSite.hashCode ^
      username.hashCode ^
      email.hashCode ^
      password.hashCode ^
      documentId.hashCode ^
      platformReference.hashCode ^
      usedRecently
          .hashCode; // Incluir el campo usado recientemente en el hashCode
}
