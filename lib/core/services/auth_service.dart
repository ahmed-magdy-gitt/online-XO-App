import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';
import '../utils/helpers.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(Helpers.mapFirebaseAuthError(e));
    } catch (_) {
      throw const AuthServiceException(AppStrings.genericError);
    }
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(Helpers.mapFirebaseAuthError(e));
    } catch (_) {
      throw const AuthServiceException(AppStrings.genericError);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(Helpers.mapFirebaseAuthError(e));
    } catch (_) {
      throw const AuthServiceException(AppStrings.genericError);
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(Helpers.mapFirebaseAuthError(e));
    } catch (_) {
      throw const AuthServiceException(AppStrings.genericError);
    }
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
