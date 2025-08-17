import 'package:app_tcc/models/contact.dart';
import 'package:app_tcc/models/contact_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactListTile extends StatefulWidget {
  const ContactListTile(this.contact, {super.key});

  final Contact contact;

  @override
  _ContactListTileState createState() => _ContactListTileState();
}

class _ContactListTileState extends State<ContactListTile> {
  String? contactLetter;
  String? relationship;

  String getInitials(String contactName) => contactName.isNotEmpty
      ? contactName.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
      : '';
  String getRelationship(bool rel) => rel == true ? 'Cliente' : 'Fornecedor';

  @override
  void initState() {
    relationship = getRelationship(widget.contact.client!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/contact', arguments: widget.contact);
      },
      child: Consumer<ContactManager>(builder: (_, contactManager, __) {
        contactLetter = getInitials(widget.contact.name!);
        return ListTile(
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 25,
            child: Text(
              '$contactLetter',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            '${widget.contact.name}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.client == true ? 'Cliente' : 'Fornecedor',
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
