import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;
  String? get email => _auth.currentUser?.email;
  String? get displayName => _auth.currentUser?.displayName;

  AuthProvider() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _errorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Имэйл бүртгэлгүй байна';
      case 'wrong-password':
        return 'Нууц үг буруу байна';
      case 'email-already-in-use':
        return 'Имэйл аль хэдийн бүртгэлтэй байна';
      case 'weak-password':
        return 'Нууц үг хэтэрхий богино байна';
      case 'invalid-email':
        return 'Имэйл хаяг буруу байна';
      case 'invalid-credential':
        return 'Имэйл эсвэл нууц үг буруу байна';
      default:
        return 'Алдаа гарлаа: $code';
    }
  }
}
