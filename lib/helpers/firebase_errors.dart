String getErrorString(String code) {
  switch (code) {
    case 'weak-password':
      return 'Sua senha é muito fraca.';

    case 'invalid-email':
      return 'Suas credenciais são inválidas.';

    case 'account-exists-with-different-credential':
      return 'E-mail já utilizado em outra conta.';

    case 'invalid-credential':
      return 'Suas credenciais estão expiradas ou são inválidas.';

    case 'user-not-found':
      return 'Não há usuário com este e-mail.';

    case 'wrong-password':
      return 'Suas credenciais são inválidas.';

    case 'user-disabled':
      return 'Este usuário foi desabilitado.';

    case 'operation-not-allowed':
      return 'Solicitações bloqueadas. Tente novamente mais tarde.';

    case 'auth/too-many-requests':
      return 'Muitas solicitações. Tente novamente mais tarde.';

    default:
      return 'Um erro indefinido ocorreu.';
  }
}
