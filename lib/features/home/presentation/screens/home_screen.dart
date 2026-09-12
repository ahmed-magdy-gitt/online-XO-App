import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../room/presentation/screens/room_screen.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';
import '../widgets/room_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            tooltip: AppStrings.joinRoom,
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RoomScreen(isCreating: false),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const RoomScreen(isCreating: true),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.createRoom),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.openRooms,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is HomeError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is HomeLoaded) {
                    final authState = context.read<AuthCubit>().state;
                    final currentUserId = authState is AuthAuthenticated
                        ? authState.user.uid
                        : '';
                    final rooms = state.waitingRooms
                        .where((room) => room.isJoinable)
                        .toList();
                    if (rooms.isEmpty) {
                      return Center(
                        child: Text(
                          'No open rooms yet.\nTap + to create one!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: rooms.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final isOwnRoom = room.hostId == currentUserId;
                        return RoomCard(
                          room: room,
                          isOwnRoom: isOwnRoom,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => RoomScreen(
                                  isCreating: false,
                                  roomId: room.roomId,
                                  resumeAsHost: isOwnRoom,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
