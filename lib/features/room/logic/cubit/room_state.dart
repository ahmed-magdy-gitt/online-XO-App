import 'package:equatable/equatable.dart';
import '../../../../core/models/room_model.dart';

abstract class RoomState extends Equatable {
  const RoomState();
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {
  const RoomInitial();
}

class RoomLoading extends RoomState {
  const RoomLoading();
}

class RoomWaiting extends RoomState {
  const RoomWaiting(this.room);
  final RoomModel room;
  @override
  List<Object?> get props => [room];
}

class RoomJoined extends RoomState {
  const RoomJoined(this.room);
  final RoomModel room;
  @override
  List<Object?> get props => [room];
}

class RoomClosed extends RoomState {
  const RoomClosed(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class RoomError extends RoomState {
  const RoomError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
