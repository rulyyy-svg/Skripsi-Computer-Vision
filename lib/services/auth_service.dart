import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi Login
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Menangani error spesifik (User tidak ditemukan, password salah, dll)
      print("Error Login: ${e.message}");
      return null;
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Cek apakah user sudah login atau belum
  Stream<User?> get userStatus {
    return _auth.authStateChanges();
  }
}
