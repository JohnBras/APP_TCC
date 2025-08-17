import 'package:app_tcc/models/contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactManager extends ChangeNotifier {
  ContactManager() {
    _loadAllContacts();
  }

  Contact? contact;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Contact> allContacts = [];

  String _search = '';
  String get search => _search;
  set search(String value) {
    _search = value;
    notifyListeners();
  }

  List<Contact> get filteredContactsByName {
    final List<Contact> filteredContactsByName = [];

    if (search.isEmpty) {
      filteredContactsByName.addAll(filteredContactsByRel);
    } else {
      filteredContactsByName.addAll(filteredContactsByRel
          .where((c) => c.name!.toLowerCase().contains(search.toLowerCase())));
    }
    print('filcon: $filteredContactsByName');

    return filteredContactsByName;
  }

  List<Contact> get filteredContactsByRel {
    final List<Contact> filteredContactsByRel = [];

    if (filteredClient == true) {
      filteredContactsByRel.addAll(allContacts.where((c) => c.client! == true));
    } else if (filteredConsumer == true) {
      filteredContactsByRel
          .addAll(allContacts.where((c) => c.client! == false));
    } else {
      filteredContactsByRel.addAll(allContacts);
    }

    return filteredContactsByRel;
  }

  Contact? findContactById(String id) {
    try {
      return allContacts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  bool _filteredClient = false;
  bool get filteredClient => _filteredClient;
  set filteredClient(bool filter) {
    _filteredClient = filter;
    notifyListeners();
  }

  bool _filteredConsumer = false;
  bool get filteredConsumer => _filteredConsumer;
  set filteredConsumer(bool filter) {
    _filteredConsumer = filter;
    notifyListeners();
  }

  Future<void> _loadAllContacts() async {
    final QuerySnapshot snapContacts = await firestore
        .collection('contacts')
        .where('deleted', isEqualTo: false)
        .get();

    allContacts =
        snapContacts.docs.map((d) => Contact.fromDocument(d)).toList();

    notifyListeners();
    print('contato carregado');
  }

  String _jurPerson = '';
  String get jurPerson => _jurPerson;
  set jurPerson(String jp) {
    _jurPerson = jp;
    notifyListeners();
  }

  void update(Contact contact) {
    final List<Contact> newContacts = [];

    for (final currentContact in allContacts) {
      if (currentContact.id != contact.id) {
        newContacts.add(currentContact);
      }
    }
    allContacts.clear();
    allContacts.addAll(newContacts);
    allContacts.add(contact);
    notifyListeners();
  }

  void delete(Contact contact) {
    contact.delete();
    allContacts.removeWhere((c) => c.id == contact.id);
    notifyListeners();
  }
}
