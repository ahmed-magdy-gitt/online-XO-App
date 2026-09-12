import '../../../../core/models/user_model.dart';
import '../../../../core/services/firestore_service.dart';

class ProfileRepository {
  ProfileRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  Stream<UserModel?> watchUser(String uid) =>
      _firestoreService.watchUser(uid);

  Future<UserModel?> getUser(String uid) => _firestoreService.getUser(uid);
}
