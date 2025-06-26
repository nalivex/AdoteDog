import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> cadastrar(String email, String senha) async {
    try {
      UserCredential usuario = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await usuario.user!.sendEmailVerification();
      return null; // Sucesso: retorna null indicando que não houve erro
    } on FirebaseAuthException catch (e) {
      return e.message; // Erro: retorna a mensagem de erro
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  Future<String?> login(String email, String senha) async {
    try {
      UserCredential usuario = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (!usuario.user!.emailVerified) {
        return 'Verfique seu email!';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message; // Erro: retorna a mensagem de erro
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<String?> trocarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message; // Erro: retorna a mensagem de erro
    } catch (e) {
      return 'Erro desconhecido: $e';
    }
  }
}
