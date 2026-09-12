import 'package:uuid/uuid.dart';
import '../../../../core/models/room_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/firestore_service.dart';

class RoomRepository {
  RoomRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService(),
        _uuid = const Uuid();

  final FirestoreService _firestoreService;
  final Uuid _uuid;

  Future<RoomModel> createRoom(UserModel creator) async {
    final room = RoomModel(
      roomId: _uuid.v4().substring(0, 8).toUpperCase(),
      creatorId: creator.uid,
      creatorName: creator.name,
      status: RoomStatus.waiting,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createRoom(room);
    return room;
  }

  Future<RoomModel?> getRoom(String roomId) =>
      _firestoreService.getRoom(roomId);

  Stream<RoomModel?> watchRoom(String roomId) =>
      _firestoreService.watchRoom(roomId);

  Future<RoomModel> joinRoom({
    required String roomId,
    required UserModel guest,
  }) {
    return _firestoreService.joinWaitingRoom(
      roomId: roomId,
      guest: guest,
    );
  }

  Future<void> cancelRoom(String roomId) =>
      _firestoreService.cancelRoom(roomId);

  Future<void> completeRoom(String roomId) =>
      _firestoreService.completeRoom(roomId);

  Future<void> startGame(RoomModel room) =>
      _firestoreService.startGame(room);

  Future<void> kickGuest(String roomId) =>
      _firestoreService.kickGuest(roomId);

  Future<void> guestLeave(String roomId) =>
      _firestoreService.guestLeave(roomId);

  Future<void> leaveRoom({
    required RoomModel room,
    required String userId,
  }) async {
    if (room.isWaiting && room.hostId == userId) {
      await _firestoreService.cancelRoom(room.roomId);
      return;
    }
    if (room.isPlaying && room.isCompleted == false) {
      return;
    }
    await _firestoreService.completeRoom(room.roomId);
  }
}
