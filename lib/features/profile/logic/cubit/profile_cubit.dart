import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._profileRepository,
    required String userId,
  })  : _userId = userId,
        super(const ProfileInitial()) {
    loadProfile();
  }

  final ProfileRepository _profileRepository;
  final String _userId;
  StreamSubscription<UserModel?>? _profileSubscription;

  /// Fetches the latest user document, then keeps listening for live updates.
  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    await _profileSubscription?.cancel();

    try {
      final latest = await _profileRepository.getUser(_userId);
      if (latest != null && !isClosed) {
        emit(ProfileLoaded(latest));
      }
    } catch (error) {
      if (!isClosed) emit(ProfileError(error.toString()));
    }

    _profileSubscription = _profileRepository.watchUser(_userId).listen(
      (user) {
        if (user == null) {
          emit(const ProfileError('Profile not found.'));
          return;
        }
        emit(ProfileLoaded(user));
      },
      onError: (Object error) => emit(ProfileError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
