import 'package:app_tcc/models/contact.dart';
import 'package:app_tcc/models/contact_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditContactScreen extends StatefulWidget {
  EditContactScreen(Contact? p)
      : editing = p != null,
        contact = p != null ? p.clone() : Contact();

  final Contact contact;
  final bool editing;

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String selectedValue = '';
  int _rel = 0;
  final _person = <String>['Pessoa Física', 'Pessoa Jurídica'];

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Gradiente do cabeçalho: forte no dark, pastel no light (mesma paleta)
    Color _lightVariant(Color base,
        {double lighten = 0.25, double desat = 0.35}) {
      final hsl = HSLColor.fromColor(base);
      final l = (hsl.lightness + lighten).clamp(0.0, 1.0);
      final s = (hsl.saturation * (1 - desat)).clamp(0.0, 1.0);
      return hsl.withLightness(l).withSaturation(s).toColor();
    }

    final headerGradientColors = isDark
        ? <Color>[cs.primary, cs.secondary, cs.tertiary]
        : <Color>[
            _lightVariant(cs.primary),
            _lightVariant(cs.secondary),
            _lightVariant(cs.tertiary),
          ];
    final headerBegin = Alignment.centerLeft;
    final headerEnd = isDark ? Alignment.centerRight : Alignment.bottomRight;

    final initials = _getInitials(widget.contact.name);

    return ChangeNotifierProvider.value(
      value: widget.contact,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,

          // título/ícones iguais aos da Home (preto no dark, branco no light)
          title: Text(
            widget.editing ? 'Editar contato' : 'Novo contato',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
          iconTheme: IconThemeData(
              color: isDark
                  ? Colors.black
                  : const Color.fromARGB(255, 255, 255, 255)),
          actionsIconTheme:
              IconThemeData(color: isDark ? Colors.black : Colors.white),
          systemOverlayStyle:
              isDark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,

          // === mesmo gradiente da Home, usando as variáveis calculadas ===
          flexibleSpace: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: headerBegin,
                  end: headerEnd,
                  colors: headerGradientColors,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          actions: [
            if (widget.editing)
              IconButton(
                tooltip: 'Excluir',
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.redAccent // escuro
                      : Colors.red, // claro
                ),
                onPressed: () {
                  context.read<ContactManager>().delete(widget.contact);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),

        // mantém o fundo e os cards conforme seu tema
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: Form(
          key: formKey,
          child: ListView(
            children: [
              // Cabeçalho com avatar e nome
              ColoredBox(
                color: cs.surfaceContainerHighest,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : cs.primary,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Center(
                        child: TextFormField(
                          initialValue: widget.contact.name,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Nome',
                            hintStyle: TextStyle(color: cs.onSurfaceVariant),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                          validator: (name) {
                            if (name == null || name.trim().length < 3) {
                              return 'Nome muito curto';
                            }
                            return null;
                          },
                          onSaved: (name) => widget.contact.name = name?.trim(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Campos
              Container(
                color: cs.surfaceContainerHighest,
                child: Column(
                  children: [
                    // Telefone
                    ListTile(
                      tileColor: cs.surfaceContainerHighest,
                      leading: Icon(Icons.phone, color: cs.primary),
                      title: Text(
                        'Telefone:',
                        style: TextStyle(
                            color: cs.onSurface, fontWeight: FontWeight.w600),
                      ),
                      subtitle: TextFormField(
                        initialValue: widget.contact.phone?.toString(),
                        style: TextStyle(color: cs.onSurface, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: '(  )     -    ',
                          hintStyle: TextStyle(color: cs.onSurfaceVariant),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (phone) {
                          final p = (phone ?? '').replaceAll(RegExp(r'\D'), '');
                          if (p.length < 8) return 'Telefone inválido';
                          return null;
                        },
                        onSaved: (phone) {
                          final p = (phone ?? '').replaceAll(RegExp(r'\D'), '');
                          widget.contact.phone = num.tryParse(p);
                        },
                      ),
                    ),
                    Divider(color: cs.outlineVariant),

                    // Endereço
                    ListTile(
                      tileColor: cs.surfaceContainerHighest,
                      leading: Icon(Icons.home_rounded, color: cs.tertiary),
                      title: Text(
                        'Endereço:',
                        style: TextStyle(
                            color: cs.onSurface, fontWeight: FontWeight.w600),
                      ),
                      subtitle: TextFormField(
                        initialValue: widget.contact.address,
                        style: TextStyle(color: cs.onSurface, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Digite o endereço',
                          hintStyle: TextStyle(color: cs.onSurfaceVariant),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        validator: (address) {
                          if ((address ?? '').trim().length < 5) {
                            return 'Endereço inválido';
                          }
                          return null;
                        },
                        onSaved: (address) =>
                            widget.contact.address = address?.trim(),
                      ),
                    ),
                    Divider(color: cs.outlineVariant),

                    // Tipo de Pessoa
                    ListTile(
                      tileColor: cs.surfaceContainerHighest,
                      leading: Icon(Icons.badge_outlined, color: cs.secondary),
                      title: Text(
                        'Tipo de Pessoa:',
                        style: TextStyle(
                            color: cs.onSurface, fontWeight: FontWeight.w600),
                      ),
                      subtitle: DropdownButtonFormField<String>(
                        dropdownColor: cs.surfaceContainerHighest,
                        isExpanded: true,
                        value: selectedValue.isEmpty ? null : selectedValue,
                        items: _person
                            .map((el) => DropdownMenuItem(
                                  value: el,
                                  child: Text(el,
                                      style: TextStyle(color: cs.onSurface)),
                                ))
                            .toList(),
                        onChanged: (newValue) =>
                            setState(() => selectedValue = newValue ?? ''),
                        hint: Text('Defina o tipo de Pessoa',
                            style: TextStyle(color: cs.onSurfaceVariant)),
                        style: TextStyle(color: cs.onSurface, fontSize: 16),
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                        onSaved: (person) => widget.contact.juridicalPerson =
                            person == _person.last,
                      ),
                    ),
                    Divider(color: cs.outlineVariant),

                    // Relacionamento
                    FormField(
                      builder: (_) => Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 4),
                            child: Text(
                              'Relacionamento:',
                              style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Radio<int>(
                                    value: 1,
                                    groupValue: _rel,
                                    onChanged: (v) => setState(() => _rel = v!),
                                    activeColor: cs.secondary,
                                  ),
                                  Text('CLIENTE',
                                      style: TextStyle(
                                          color: cs.onSurface,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<int>(
                                    value: 2,
                                    groupValue: _rel,
                                    onChanged: (v) => setState(() => _rel = v!),
                                    activeColor: cs.secondary,
                                  ),
                                  Text('FORNECEDOR',
                                      style: TextStyle(
                                          color: cs.onSurface,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      onSaved: (_) => widget.contact.client = _rel == 1,
                    ),

                    const SizedBox(height: 20),

                    // Botão Salvar
                    Consumer<Contact>(
                      builder: (_, contact, __) {
                        return SizedBox(
                          height: 48,
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: ElevatedButton(
                            onPressed: !contact.loading
                                ? () async {
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();
                                      await contact.save();
                                      context
                                          .read<ContactManager>()
                                          .update(contact);
                                      if (mounted) Navigator.of(context).pop();
                                    }
                                  }
                                : null,
                            child: contact.loading
                                ? CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(cs.onPrimary))
                                : const Text('Salvar',
                                    style: TextStyle(fontSize: 18.0)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
