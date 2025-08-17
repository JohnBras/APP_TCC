import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Contact extends ChangeNotifier {
  String? id;
  String? name;
  String? address;
  num? phone;
  bool? juridicalPerson;
  bool? client;

  bool? deleted = false;

  Contact(
      {this.id,
      this.name,
      this.address,
      this.phone,
      this.juridicalPerson,
      this.client,
      this.deleted = false});

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentReference get contactRef => firestore.doc('contacts/$id');
  CollectionReference get cartRef => firestore.collection('cart');

  Contact.fromDocument(DocumentSnapshot document) {
    id = document.id;
    name = document['name'] as String;
    address = document['address'] as String;
    phone = document['phone'] as num;
    juridicalPerson = document['juridicalPerson'] as bool;
    client = document['client'] as bool;
    deleted = (document['deleted'] ?? false) as bool;
  }

  String get cleanPhone => phone!.toString().replaceAll(RegExp(r"[^\d]"), "");

  Future<void> save() async {
    loading = true;

    final Map<String, dynamic> data = {
      'name': name,
      'address': address,
      'phone': phone,
      'juridicalPerson': juridicalPerson,
      'client': client,
      'deleted': false,
    };

    if (id == null) {
      final doc = await firestore.collection('contacts').add(data);
      id = doc.id;
    } else {
      await contactRef.update(data);
    }

    loading = false;
  }

  Contact clone() {
    return Contact(
      id: id,
      name: name,
      address: address,
      phone: phone,
      juridicalPerson: juridicalPerson,
      client: client,
      deleted: deleted,
    );
  }

  void delete() {
    contactRef.update({'deleted': true});
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, address: $address, phone: $phone, juridicalPerson: $juridicalPerson, client: $client, deleted: $deleted}';
  }
}
