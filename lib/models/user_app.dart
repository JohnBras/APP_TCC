import 'package:cloud_firestore/cloud_firestore.dart';

class UserApp {
  String? id;
  String? name;
  String? email;
  String? password;
  String? confirmPassword;

  UserApp({this.name, this.email, this.password, this.id});

  UserApp.fromDocument(DocumentSnapshot document) {
    id = document.id;
    name = document['name'] as String;
    email = document['email'] as String;
  }

  DocumentReference get firestoreRef =>
      FirebaseFirestore.instance.doc('users/$id');

  Future<void> saveData() async {
    await firestoreRef.set(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}
