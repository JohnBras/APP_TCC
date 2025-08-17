import 'package:app_tcc/helpers/validators.dart';
import 'package:app_tcc/models/user_app.dart';
import 'package:app_tcc/models/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  final UserApp userApp = UserApp();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final UserApp user = UserApp();
  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Cadastro'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Container(
        color: isDark ? null : Colors.white,
        child: Center(
          child: Column(
            children: [
              // Cabeçalho sem fundo
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 24),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.asset('assets/image_login.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Planeta Bola Esportes'.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 4,
                        fontSize: 32,
                        fontFamily: 'MrsEavesOT',
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestão de Vendas',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Formulário de cadastro
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    elevation: isDark ? 4 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: formKey,
                      child: Consumer<UserManager>(
                        builder: (_, userManager, __) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Nome completo',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  keyboardType: TextInputType.name,
                                  autocorrect: false,
                                  validator: (name) {
                                    if (name!.isEmpty) {
                                      return 'Campo obrigatório';
                                    } else if (name.trim().split(' ').length <=
                                        1) {
                                      return 'Preencha seu nome completo';
                                    }
                                    return null;
                                  },
                                  onSaved: (name) => userApp.name = name,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  validator: (email) {
                                    if (email!.isEmpty) {
                                      return 'Campo obrigatório';
                                    } else if (!emailValid(email)) {
                                      return 'E-mail inválido';
                                    }
                                    return null;
                                  },
                                  onSaved: (email) => userApp.email = email,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Senha',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  autocorrect: false,
                                  obscureText: true,
                                  validator: (pw) {
                                    if (pw!.isEmpty) {
                                      return 'Campo obrigatório';
                                    } else if (pw.length < 6) {
                                      return 'Senha inválida';
                                    }
                                    return null;
                                  },
                                  onSaved: (pw) => userApp.password = pw,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Repita a senha',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  autocorrect: false,
                                  obscureText: true,
                                  validator: (rpw) {
                                    if (rpw!.isEmpty) {
                                      return 'Campo obrigatório';
                                    } else if (rpw.length < 6) {
                                      return 'Senha inválida';
                                    }
                                    return null;
                                  },
                                  onSaved: (rpw) =>
                                      userApp.confirmPassword = rpw,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cs.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          cs.primary.withOpacity(0.12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        formKey.currentState!.save();
                                        if (user.password !=
                                            user.confirmPassword) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Senhas não coincidem!'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        userManager.signUp(
                                          userApp: userApp,
                                          onSuccess: () {
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                              '/base',
                                              (_) => false,
                                            );
                                          },
                                          onFail: (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Falha ao realizar cadastro: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: userManager.loading
                                        ? const CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                          )
                                        : const Text(
                                            'Criar conta',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Já tem uma conta? Faça login',
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
