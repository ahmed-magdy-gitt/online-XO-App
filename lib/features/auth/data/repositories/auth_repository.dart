import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';

class AuthRepository {
  AuthRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  final AuthService _authService;
  final FirestoreService _firestoreService;

  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      final profile = await _firestoreService.getUser(user.uid);
      return profile ??
          UserModel(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
          );
    });
  }

  Future<UserModel?> restoreSession() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    final profile = await _firestoreService.getUser(user.uid);
    return profile ??
        UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
        );
  }

  UserModel? get currentUserCache {
    final user = _authService.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
    );
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    final user = credential.user!;
    final profile = await _firestoreService.getUser(user.uid);

    return profile ??
        UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
        );
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.registerWithEmail(
      email: email,
      password: password,
    );

    final user = credential.user!;
    await _authService.updateDisplayName(name);

    final userModel = UserModel(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
    );

    await _firestoreService.createUser(userModel);
    return userModel;
  }

  Future<void> signOut() => _authService.signOut();
}
