import 'package:equatable/equatable.dart';

import '../../../../core/models/room_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({this.waitingRooms = const []});
  final List<RoomModel> waitingRooms;
  @override
  List<Object?> get props => [waitingRooms];
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
