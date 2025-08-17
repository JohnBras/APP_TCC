// CODIGO DE Detalhe do contato

import 'package:app_tcc/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:app_tcc/models/theme_mode_manager.dart';

class ContactScreen extends StatefulWidget {
  final Contact? contact;
  const ContactScreen({super.key, this.contact});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late Contact editingContact;

  @override
  void initState() {
    super.initState();
    editingContact =
        widget.contact != null ? widget.contact!.clone() : Contact();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeMgr = context.watch<ThemeModeManager>();
    final isDark = themeMgr.mode == ThemeMode.dark;

    // 🎯 CORES PRINCIPAIS — altere aqui:
    final Color pageBg = cs.surfaceContainerHighest; // Fundo geral igual lista
    final Color cardBg = cs.surface; // Fundo dos cards igual lista
    final Color onCard = cs.onSurface; // Texto e ícones

    // gradiente pastel no claro

    String getInitials(String? contactName) {
      if (contactName == null || contactName.isEmpty) return '';
      return contactName
          .trim()
          .split(RegExp(' +'))
          .map((s) => s[0])
          .take(2)
          .join();
    }

    final String contactLetter = getInitials(editingContact.name ?? '');

    Future<void> openPhone() async {
      final clean = editingContact.cleanPhone;
      final uri = Uri(scheme: 'tel', path: clean);
      if (clean.isNotEmpty && await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Esta função não está disponível neste dispositivo'),
            backgroundColor: cs.error,
          ),
        );
      }
    }

    return ChangeNotifierProvider.value(
      value: editingContact,
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,

          title: Text(
            'Contato',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
          actionsIconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
          systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,

          // === mesmo gradiente da Home ===
          flexibleSpace: IgnorePointer(
            child: Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                Color lightVariant(Color base,
                    {double lighten = 0.25, double desat = 0.35}) {
                  final h = HSLColor.fromColor(base);
                  final l = (h.lightness + lighten).clamp(0.0, 1.0);
                  final s = (h.saturation * (1 - desat)).clamp(0.0, 1.0);
                  return h.withLightness(l).withSaturation(s).toColor();
                }

                final isDark = Theme.of(context).brightness == Brightness.dark;
                final colors = isDark
                    ? [cs.primary, cs.secondary, cs.tertiary]
                    : [
                        lightVariant(cs.primary),
                        lightVariant(cs.secondary),
                        lightVariant(cs.tertiary)
                      ];

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // linha sutil na base (igual Home “clean”)
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Builder(
              builder: (context) => Container(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.6),
              ),
            ),
          ),

          actions: [
            if (editingContact.deleted == false)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    '/edit_contact',
                    arguments: editingContact,
                  );
                },
              ),
          ],
        ),
        body: ListView(
          children: [
            // Header (avatar + nome)
            ColoredBox(
              color: pageBg, // preto no topo
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: isDark ? Colors.black : cs.primary,
                    child: Text(
                      contactLetter,
                      style: const TextStyle(color: Colors.white, fontSize: 36),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      editingContact.name ?? '',
                      style: TextStyle(
                        color: onCard,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Lista de detalhes
            Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tileColor: cardBg,
                  leading: GestureDetector(
                    onTap: openPhone,
                    child: Icon(Icons.phone, color: onCard),
                  ),
                  title: Text('Telefone:',
                      style: TextStyle(color: onCard.withOpacity(.7))),
                  subtitle: Text(
                    (editingContact.phone ?? '').toString(),
                    style:
                        TextStyle(fontWeight: FontWeight.w500, color: onCard),
                  ),
                ),
                Divider(color: cs.outlineVariant),

                ListTile(
                  tileColor: cardBg,
                  leading: Icon(Icons.home_rounded, color: onCard),
                  title: Text('Endereço:',
                      style: TextStyle(color: onCard.withOpacity(.7))),
                  subtitle: Text(
                    editingContact.address ?? '',
                    style:
                        TextStyle(fontWeight: FontWeight.w500, color: onCard),
                  ),
                ),
                Divider(color: cs.outlineVariant),

                ListTile(
                  tileColor: cardBg,
                  leading: Icon(Icons.assignment_ind, color: onCard),
                  title: Text('Tipo de Pessoa:',
                      style: TextStyle(color: onCard.withOpacity(.7))),
                  subtitle: Text(
                    editingContact.juridicalPerson == true
                        ? 'Pessoa Jurídica'
                        : 'Pessoa Física',
                    style:
                        TextStyle(fontWeight: FontWeight.w500, color: onCard),
                  ),
                ),
                Divider(color: cs.outlineVariant),

                // Relacionamento
                Center(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: onCard),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 4),
                          child: Text('Relacionamento:',
                              style: TextStyle(fontSize: 15)),
                        ),
                        Text(
                          editingContact.client == true
                              ? 'CLIENTE'
                              : 'FORNECEDOR',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
