import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/room_model.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this._homeRepository})
      : super(const HomeInitial()) {
    loadWaitingRooms();
  }

  final HomeRepository _homeRepository;
  StreamSubscription<List<RoomModel>>? _roomsSubscription;

  void loadWaitingRooms() {
    emit(const HomeLoading());
    _roomsSubscription?.cancel();
    _roomsSubscription =
        _homeRepository.watchWaitingRooms().listen(
      (rooms) => emit(HomeLoaded(waitingRooms: rooms)),
      onError: (Object error) => emit(HomeError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _roomsSubscription?.cancel();
    return super.close();
  }
}
