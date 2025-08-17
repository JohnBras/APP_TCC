import 'package:app_tcc/models/contact_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactFilterDrawer extends StatefulWidget {
  late final String title;

  @override
  _ContactFilterDrawerState createState() => _ContactFilterDrawerState();
}

class _ContactFilterDrawerState extends State<ContactFilterDrawer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Color primaryColor = Theme.of(context).primaryColor;
    return Consumer<ContactManager>(
      builder: (_, contactManager, __) {
        return SizedBox(
          width: 280,
          child: Drawer(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          width: MediaQuery.of(context).size.width * 1,
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              'Filtrar contatos',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                foregroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.white.withOpacity(0.5);
                                  } else {
                                    return Colors.white;
                                  }
                                }),
                              ),
                              child: const SizedBox(
                                width: 116,
                                child: Text(
                                  'Exibir somente clientes',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Switch(
                                  value: contactManager.filteredClient,
                                  onChanged: (newState) {
                                    setState(() {
                                      contactManager.filteredClient =
                                          !contactManager.filteredClient;
                                      contactManager.filteredConsumer == true
                                          ? contactManager.filteredConsumer =
                                              false
                                          : contactManager.filteredConsumer =
                                              false;
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        const Divider(
                          color: Colors.black54,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                foregroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.white.withOpacity(0.5);
                                  } else {
                                    return Colors.white;
                                  }
                                }),
                              ),
                              child: const SizedBox(
                                width: 116,
                                child: Text(
                                  'Exibir somente fornecedores',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Switch(
                                  value: contactManager.filteredConsumer,
                                  onChanged: (newState) {
                                    setState(() {
                                      contactManager.filteredConsumer =
                                          !contactManager.filteredConsumer;
                                      contactManager.filteredClient == true
                                          ? contactManager.filteredClient =
                                              false
                                          : contactManager.filteredClient =
                                              false;
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 60),
                        TextButton(
                          child: const Center(
                            child: Text(
                              'Limpar filtro',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              contactManager.filteredClient = false;
                              contactManager.filteredConsumer = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
