import '../../../../core/models/room_model.dart';
import '../../../../core/services/firestore_service.dart';

class HomeRepository {
  HomeRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  Stream<List<RoomModel>> watchWaitingRooms() =>
      _firestoreService.watchWaitingRooms();
}
