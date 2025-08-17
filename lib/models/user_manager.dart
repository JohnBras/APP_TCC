import 'package:app_tcc/helpers/firebase_errors.dart';
import 'package:app_tcc/models/user_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserManager extends ChangeNotifier {
  UserManager() {
    _loadCurrentUser();
  }

  UserApp? user;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _loading = false;
  bool get loading => _loading;

  bool _initLoading = false;
  bool get initLoading => _initLoading;

  bool get isLoggedIn => user != null;

  set loading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  set initLoading(bool value) {
    if (_initLoading == value) return;
    _initLoading = value;
    notifyListeners();
  }

  /// LOGIN
  Future<void> signIn({
    required UserApp userApp,
    void Function(String message)? onFail,
    VoidCallback? onSuccess,
  }) async {
    loading = true;
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: userApp.email!.trim(),
        password: userApp.password!,
      );
      await _loadCurrentUser(firebaseUser: cred.user);
      onSuccess?.call();
    } on FirebaseAuthException catch (e) {
      onFail?.call(getErrorString(e.code));
    } catch (_) {
      onFail?.call('Falha inesperada ao fazer login.');
    } finally {
      loading = false;
    }
  }

  /// LOGOUT (assíncrono)
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } finally {
      user = null;
      notifyListeners();
    }
  }

  /// CADASTRO
  Future<void> signUp({
    required UserApp userApp,
    void Function(String message)? onFail,
    VoidCallback? onSuccess,
  }) async {
    loading = true;
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: userApp.email!.trim(),
        password: userApp.password!,
      );

      userApp.id = cred.user!.uid;
      user = userApp;

      await userApp.saveData();
      onSuccess?.call();
    } on FirebaseAuthException catch (e) {
      onFail?.call(getErrorString(e.code));
    } catch (_) {
      onFail?.call('Falha inesperada ao criar conta.');
    } finally {
      loading = false;
    }
  }

  /// RECUPERAR SENHA
  Future<void> recoverPass({
    required String email,
    void Function(String message)? onFail,
    VoidCallback? onSuccess,
  }) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      onSuccess?.call();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      onFail?.call(getErrorString(e.code));
    }
  }

  /// CARREGAR USUÁRIO LOGADO (se houver)
  Future<void> _loadCurrentUser({User? firebaseUser}) async {
    initLoading = true;
    try {
      final current = firebaseUser ?? auth.currentUser;
      if (current != null) {
        final docUser =
            await firestore.collection('users').doc(current.uid).get();
        if (docUser.exists) {
          user = UserApp.fromDocument(docUser);
        } else {
          user = null;
        }
      } else {
        user = null;
      }
    } finally {
      initLoading = false;
      notifyListeners();
    }
  }
}
