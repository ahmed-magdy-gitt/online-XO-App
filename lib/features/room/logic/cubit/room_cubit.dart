import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/room_model.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repositories/room_repository.dart';
import 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  RoomCubit({required this._roomRepository}) : super(const RoomInitial());

  final RoomRepository _roomRepository;
  StreamSubscription<RoomModel?>? _roomSubscription;
  String? _watchedRoomId;
  String? _currentUserId;
  bool _guestSeatConfirmed = false;

  Future<void> createRoom(UserModel creator) async {
    emit(const RoomLoading());
    _currentUserId = creator.uid;
    _guestSeatConfirmed = false;
    try {
      final room = await _roomRepository.createRoom(creator);
      _watchRoom(room.roomId);
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> joinOrResume({
    required String roomId,
    required UserModel user,
  }) async {
    emit(const RoomLoading());
    _currentUserId = user.uid;
    _guestSeatConfirmed = false;
    try {
      final room = await _roomRepository.getRoom(roomId);
      if (room == null || room.isCancelled) {
        emit(const RoomError(AppStrings.roomUnavailable));
        return;
      }
      if (room.isCompleted) {
        emit(const RoomError('This match has already finished.'));
        return;
      }

      if (room.hostId == user.uid) {
        _watchRoom(roomId);
        return;
      }

      if (room.gameStarted) {
        if (room.guestId == user.uid) {
          _watchRoom(roomId);
          return;
        }
        emit(const RoomError('Room is already full.'));
        return;
      }

      if (room.isFull && room.guestId != user.uid) {
        emit(const RoomError('Room is already full.'));
        return;
      }

      if (room.guestId == user.uid) {
        _watchRoom(roomId);
        return;
      }

      if (!room.isJoinable) {
        emit(const RoomError(AppStrings.roomUnavailable));
        return;
      }

      _watchRoom(roomId);
      final joined = await _roomRepository.joinRoom(roomId: roomId, guest: user);
      emit(RoomWaiting(joined));
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> joinRoom({
    required String roomId,
    required UserModel opponent,
  }) {
    return joinOrResume(roomId: roomId, user: opponent);
  }

  Future<void> startGame() async {
    final current = state;
    if (current is! RoomWaiting) return;
    if (current.room.hostId != _currentUserId) return;
    if (!current.room.canStartGame) return;

    try {
      await _roomRepository.startGame(current.room);
    } catch (e) {
      emit(RoomError(e.toString()));
      _watchRoom(current.room.roomId);
    }
  }

  Future<void> kickGuest() async {
    final current = state;
    if (current is! RoomWaiting) return;
    if (current.room.hostId != _currentUserId) return;
    try {
      await _roomRepository.kickGuest(current.room.roomId);
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> guestLeave() async {
    final current = state;
    if (current is! RoomWaiting) return;
    final roomId = current.room.roomId;
    await _roomSubscription?.cancel();
    _roomSubscription = null;
    _watchedRoomId = null;
    _guestSeatConfirmed = false;
    try {
      await _roomRepository.guestLeave(roomId);
    } catch (_) {
      // Guest is leaving locally regardless of the write result.
    }
    emit(const RoomInitial());
  }

  void _watchRoom(String roomId) {
    _watchedRoomId = roomId;
    _roomSubscription?.cancel();
    _roomSubscription = _roomRepository.watchRoom(roomId).listen(
      (room) {
        if (room == null || room.isCancelled) {
          emit(const RoomClosed(AppStrings.roomUnavailable));
          return;
        }
        if (room.isCompleted) {
          emit(const RoomClosed('This match has already finished.'));
          return;
        }

        final userId = _currentUserId;
        final isHost = userId != null && userId == room.hostId;
        final isSeatedGuest = userId != null && room.guestId == userId;

        if (isSeatedGuest) {
          _guestSeatConfirmed = true;
        } else if (!isHost && userId != null) {
          // Only treat this as a kick after a snapshot already proved we were
          // seated. Ignore join-in-progress / cached docs where guestId is null.
          if (_guestSeatConfirmed) {
            emit(const RoomClosed(AppStrings.kickedFromRoom));
            return;
          }
          return;
        }

        if (room.gameStarted) {
          emit(RoomJoined(room));
          return;
        }

        emit(RoomWaiting(room));
      },
      onError: (Object error) => emit(RoomError(error.toString())),
    );
  }

  Future<void> cancelWaitingRoom() async {
    final state = this.state;
    final room = state is RoomWaiting
        ? state.room
        : state is RoomJoined
            ? state.room
            : null;
    final roomId = room?.roomId ?? _watchedRoomId;
    await _roomSubscription?.cancel();
    _roomSubscription = null;
    _watchedRoomId = null;
    _guestSeatConfirmed = false;
    if (roomId != null && (room == null || room.hostId == _currentUserId)) {
      await _roomRepository.cancelRoom(roomId);
    }
    emit(const RoomInitial());
  }

  Future<void> completeRoom(String roomId) async {
    await _roomRepository.completeRoom(roomId);
  }

  Future<void> reset() async {
    await _roomSubscription?.cancel();
    _roomSubscription = null;
    _watchedRoomId = null;
    _guestSeatConfirmed = false;
    emit(const RoomInitial());
  }

  @override
  Future<void> close() {
    _roomSubscription?.cancel();
    return super.close();
  }
}
