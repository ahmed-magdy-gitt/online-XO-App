import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/services/auth_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/firestore_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/game/data/repositories/game_repository.dart';
import 'features/home/data/repositories/home_repository.dart';
import 'features/home/logic/cubit/home_cubit.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/room/data/repositories/room_repository.dart';
import 'features/room/logic/cubit/room_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.instance.initialize();

  runApp(const ExomaniaAppRoot());
}

class ExomaniaAppRoot extends StatelessWidget {
  const ExomaniaAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(create: (_) => AuthService()),
        RepositoryProvider<FirestoreService>(create: (_) => FirestoreService()),
        
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            authService: context.read<AuthService>(),
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        RepositoryProvider<HomeRepository>(
          create: (context) => HomeRepository(
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        RepositoryProvider<RoomRepository>(
          create: (context) => RoomRepository(
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        RepositoryProvider<GameRepository>(
          create: (context) => GameRepository(
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<HomeCubit>(
            create: (context) => HomeCubit(
              homeRepository: context.read<HomeRepository>(),
            ),
          ),
          BlocProvider<RoomCubit>(
            create: (context) => RoomCubit(
              roomRepository: context.read<RoomRepository>(),
            ),
          ),
        ],
        child: const ExomaniaApp(),
      ),
    );
  }
}
