import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_strings.dart';
import '../models/game_model.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../utils/helpers.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String usersCollection = 'users';
  static const String roomsCollection = 'rooms';
  static const String gamesCollection = 'games';

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(usersCollection);

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection(roomsCollection);

  CollectionReference<Map<String, dynamic>> get _games =>
      _firestore.collection(gamesCollection);

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<void> createUser(UserModel user) async {
    try {
      await _users.doc(user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

 
  Future<void> recordMatchStats({
    required String gameId,
    required String creatorId,
    required String opponentId,
    required String? winnerId,
    required bool isDraw,
  }) async {
    if (creatorId.isEmpty || opponentId.isEmpty) return;

    try {
      await _firestore.runTransaction((transaction) async {
        final gameRef = _games.doc(gameId);
        final creatorRef = _users.doc(creatorId);
        final opponentRef = _users.doc(opponentId);

        final gameSnap = await transaction.get(gameRef);
        if (!gameSnap.exists) return;
        if (gameSnap.data()?['statsRecorded'] == true) return;

        final creatorSnap = await transaction.get(creatorRef);
        final opponentSnap = await transaction.get(opponentRef);

        if (isDraw) {
          _writeStatIncrement(
            transaction,
            creatorRef,
            creatorSnap,
            winsDelta: 0,
            lossesDelta: 0,
            drawsDelta: 1,
          );
          _writeStatIncrement(
            transaction,
            opponentRef,
            opponentSnap,
            winsDelta: 0,
            lossesDelta: 0,
            drawsDelta: 1,
          );
        } else if (winnerId == creatorId || winnerId == opponentId) {
          final winnerRef = winnerId == creatorId ? creatorRef : opponentRef;
          final winnerSnap = winnerId == creatorId ? creatorSnap : opponentSnap;
          final loserRef = winnerId == creatorId ? opponentRef : creatorRef;
          final loserSnap = winnerId == creatorId ? opponentSnap : creatorSnap;

          _writeStatIncrement(
            transaction,
            winnerRef,
            winnerSnap,
            winsDelta: 1,
            lossesDelta: 0,
            drawsDelta: 0,
          );
          _writeStatIncrement(
            transaction,
            loserRef,
            loserSnap,
            winsDelta: 0,
            lossesDelta: 1,
            drawsDelta: 0,
          );
        }

        transaction.update(gameRef, {'statsRecorded': true});
        transaction.set(
          _rooms.doc(gameId),
          {'status': RoomStatus.completed.value},
          SetOptions(merge: true),
        );
      });
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  void _writeStatIncrement(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> ref,
    DocumentSnapshot<Map<String, dynamic>> snap, {
    required int winsDelta,
    required int lossesDelta,
    required int drawsDelta,
  }) {
    final data = snap.data() ?? {};
    final wins = ((data['wins'] as num?)?.toInt() ?? 0) + winsDelta;
    final currentTotal = (data['totalGames'] as num?)?.toInt() ??
        ((data['wins'] as num?)?.toInt() ?? 0) +
            ((data['losses'] as num?)?.toInt() ?? 0) +
            ((data['draws'] as num?)?.toInt() ?? 0);
    final totalGames = currentTotal + 1;
    final winRate = totalGames == 0 ? 0.0 : (wins / totalGames) * 100;

    final updates = <String, dynamic>{
      'totalGames': FieldValue.increment(1),
      'winRate': winRate,
    };
    if (winsDelta != 0) {
      updates['wins'] = FieldValue.increment(winsDelta);
    }
    if (lossesDelta != 0) {
      updates['losses'] = FieldValue.increment(lossesDelta);
    }
    if (drawsDelta != 0) {
      updates['draws'] = FieldValue.increment(drawsDelta);
    }

    transaction.set(ref, updates, SetOptions(merge: true));
  }

  // ── Rooms ──────────────────────────────────────────────────────────────────

  Future<void> createRoom(RoomModel room) async {
    try {
      await _rooms.doc(room.roomId).set(room.toMap());
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final doc = await _rooms.doc(roomId).get();
      if (!doc.exists || doc.data() == null) return null;
      return RoomModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Stream<RoomModel?> watchRoom(String roomId) {
    return _rooms.doc(roomId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return RoomModel.fromMap(doc.data()!);
    });
  }

  Stream<List<RoomModel>> watchWaitingRooms() {
    return _rooms
        .where('status', isEqualTo: RoomStatus.waiting.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data()))
          .where((room) => room.isJoinable)
          .toList();
    });
  }

  Future<void> updateRoom(RoomModel room) async {
    try {
      await _rooms.doc(room.roomId).update(room.toMap());
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<void> setRoomStatus(String roomId, RoomStatus status) async {
    try {
      await _rooms.doc(roomId).update({'status': status.value});
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') return;
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<RoomModel> joinWaitingRoom({
    required String roomId,
    required UserModel guest,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final roomRef = _rooms.doc(roomId);
        final snapshot = await transaction.get(roomRef);

        if (!snapshot.exists || snapshot.data() == null) {
          throw const FirestoreServiceException('Room not found.');
        }

        final room = RoomModel.fromMap(snapshot.data()!);
        if (room.hostId == guest.uid) {
          throw const FirestoreServiceException(
            'You are the host of this room.',
          );
        }
        if (!room.isJoinable) {
          throw const FirestoreServiceException(AppStrings.roomUnavailable);
        }

        transaction.update(roomRef, {
          'guestId': guest.uid,
          'guestName': guest.name,
          'opponentId': guest.uid,
          'opponentName': guest.name,
          'status': RoomStatus.playing.value,
          'gameStarted': false,
        });

        return room.copyWith(
          opponentId: guest.uid,
          opponentName: guest.name,
          status: RoomStatus.playing,
          gameStarted: false,
        );
      });
    } on FirestoreServiceException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<void> startGame(RoomModel room) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final roomRef = _rooms.doc(room.roomId);
        final snapshot = await transaction.get(roomRef);
        if (!snapshot.exists || snapshot.data() == null) {
          throw const FirestoreServiceException('Room not found.');
        }
        final latest = RoomModel.fromMap(snapshot.data()!);
        if (!latest.canStartGame) {
          throw const FirestoreServiceException(
            'Both players must be in the lobby to start.',
          );
        }

        final game = GameModel.initial(
          gameId: latest.roomId,
          roomId: latest.roomId,
          startingPlayerId: latest.hostId,
        );

        transaction.update(roomRef, {
          'gameStarted': true,
          'status': RoomStatus.playing.value,
        });
        transaction.set(_games.doc(latest.roomId), game.toMap());
      });
    } on FirestoreServiceException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<void> kickGuest(String roomId) async {
    try {
      await _rooms.doc(roomId).update({
        'guestId': FieldValue.delete(),
        'guestName': FieldValue.delete(),
        'opponentId': FieldValue.delete(),
        'opponentName': FieldValue.delete(),
        'status': RoomStatus.waiting.value,
        'gameStarted': false,
      });
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<void> guestLeave(String roomId) => kickGuest(roomId);

  Future<void> forfeitTurn({
    required String gameId,
    required String expectedTurnUid,
    required String nextPlayerId,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final gameRef = _games.doc(gameId);
        final snapshot = await transaction.get(gameRef);
        if (!snapshot.exists || snapshot.data() == null) return;

        final game = GameModel.fromMap(snapshot.data()!);
        if (game.isFinished) return;
        if (game.currentTurn != expectedTurnUid) return;

        final elapsed =
            DateTime.now().millisecondsSinceEpoch - game.turnStartTime;
        if (elapsed < Helpers.turnDurationSeconds * 1000) return;

        transaction.update(gameRef, {
          'currentTurn': nextPlayerId,
          'turnStartTime': DateTime.now().millisecondsSinceEpoch,
        });
      });
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<void> cancelRoom(String roomId) async {
    await setRoomStatus(roomId, RoomStatus.cancelled);
  }

  Future<void> completeRoom(String roomId) async {
    await setRoomStatus(roomId, RoomStatus.completed);
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _rooms.doc(roomId).delete();
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  // ── Games ──────────────────────────────────────────────────────────────────

  Future<void> createGame(GameModel game) async {
    try {
      await _games.doc(game.gameId).set(game.toMap());
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Future<GameModel?> getGame(String gameId) async {
    try {
      final doc = await _games.doc(gameId).get();
      if (!doc.exists || doc.data() == null) return null;
      return GameModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  Stream<GameModel?> watchGame(String gameId) {
    return _games.doc(gameId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return GameModel.fromMap(doc.data()!);
    });
  }

  Future<void> updateGame(GameModel game) async {
    try {
      await _games.doc(game.gameId).update(game.toMap());
    } on FirebaseException catch (e) {
      throw FirestoreServiceException(_mapFirestoreError(e));
    } catch (_) {
      throw const FirestoreServiceException(AppStrings.genericError);
    }
  }

  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested resource was not found.';
      case 'unavailable':
        return AppStrings.networkError;
      case 'already-exists':
        return 'This resource already exists.';
      default:
        return e.message ?? AppStrings.genericError;
    }
  }
}

class FirestoreServiceException implements Exception {
  const FirestoreServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
