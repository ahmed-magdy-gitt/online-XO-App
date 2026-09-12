import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/room_model.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../../logic/cubit/room_cubit.dart';
import '../../logic/cubit/room_state.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({
    super.key,
    required this.isCreating,
    this.roomId,
    this.resumeAsHost = false,
  });

  final bool isCreating;
  final String? roomId;
  final bool resumeAsHost;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _roomIdController = TextEditingController();
  bool _initialized = false;
  bool _navigatingToGame = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.isCreating && widget.roomId == null) {
        context.read<RoomCubit>().reset();
      } else {
        _initializeRoom();
      }
    });
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _initializeRoom() {
    if (_initialized) return;
    _initialized = true;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final cubit = context.read<RoomCubit>();

    if (widget.isCreating) {
      cubit.createRoom(authState.user);
    } else if (widget.roomId != null) {
      cubit.joinOrResume(roomId: widget.roomId!, user: authState.user);
    }
  }

  void _joinRoom() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final roomId = _roomIdController.text.trim().toUpperCase();
    if (roomId.isEmpty) {
      AppDialogs.showErrorSnackBar(context, 'Please enter a room code.');
      return;
    }

    context.read<RoomCubit>().joinOrResume(
          roomId: roomId,
          user: authState.user,
        );
  }

  String? get _currentUserId {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) return authState.user.uid;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomCubit, RoomState>(
      listenWhen: (previous, current) {
        if (current is RoomJoined) return previous is! RoomJoined;
        return current is RoomError || current is RoomClosed;
      },
      listener: (context, state) {
        if (state is RoomError) {
          AppDialogs.showErrorSnackBar(context, state.message);
          if ((widget.roomId != null || widget.isCreating) &&
              Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else if (state is RoomClosed) {
          AppDialogs.showErrorSnackBar(context, state.message);
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else if (state is RoomJoined) {
          _navigatingToGame = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => GameScreen(room: state.room),
            ),
          );
        }
      },
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop || _navigatingToGame) return;
          final cubit = context.read<RoomCubit>();
          final state = cubit.state;
          if (state is! RoomWaiting) return;
          final userId = _currentUserId;
          if (userId == state.room.hostId) {
            cubit.cancelWaitingRoom();
          } else {
            cubit.guestLeave();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isCreating || widget.resumeAsHost
                  ? AppStrings.createRoom
                  : AppStrings.joinRoom,
            ),
          ),
          body: BlocBuilder<RoomCubit, RoomState>(
            builder: (context, state) {
              if (state is RoomLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is RoomWaiting) {
                return _LobbyView(
                  room: state.room,
                  currentUserId: _currentUserId ?? '',
                );
              }

              if (!widget.isCreating && widget.roomId == null) {
                return _JoinForm(
                  controller: _roomIdController,
                  onJoin: _joinRoom,
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

class _LobbyView extends StatelessWidget {
  const _LobbyView({
    required this.room,
    required this.currentUserId,
  });

  final RoomModel room;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final isHost = currentUserId == room.hostId;
    final guestJoined = room.isFull;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${AppStrings.roomCode}: ${room.roomId}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            guestJoined
                ? AppStrings.waitingForHostToStart
                : AppStrings.waitingForOpponent,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          _PlayerTile(
            label: AppStrings.player1,
            name: room.creatorName,
            ready: true,
          ),
          const SizedBox(height: 12),
          _PlayerTile(
            label: AppStrings.player2,
            name: room.opponentName,
            ready: guestJoined,
          ),
          const Spacer(),
          if (isHost) ...[
            ElevatedButton(
              onPressed: guestJoined
                  ? () => context.read<RoomCubit>().startGame()
                  : null,
              child: const Text(AppStrings.startGame),
            ),
            const SizedBox(height: 12),
            if (guestJoined)
              OutlinedButton(
                onPressed: () => context.read<RoomCubit>().kickGuest(),
                child: const Text(AppStrings.kickPlayer),
              )
            else
              OutlinedButton(
                onPressed: () async {
                  await context.read<RoomCubit>().cancelWaitingRoom();
                  if (context.mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(AppStrings.cancel),
              ),
          ] else ...[
            OutlinedButton(
              onPressed: () async {
                await context.read<RoomCubit>().guestLeave();
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(AppStrings.leaveRoom),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.label,
    required this.name,
    required this.ready,
  });

  final String label;
  final String? name;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ready
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.cardDark,
          child: Icon(
            ready ? Icons.person : Icons.person_outline,
            color: ready ? AppColors.primary : AppColors.textSecondaryDark,
          ),
        ),
        title: Text(label),
        subtitle: Text(
          ready ? (name ?? 'Player') : AppStrings.waitingForOpponent,
        ),
      ),
    );
  }
}

class _JoinForm extends StatelessWidget {
  const _JoinForm({
    required this.controller,
    required this.onJoin,
  });

  final TextEditingController controller;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: AppStrings.roomCode,
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onJoin,
            child: const Text(AppStrings.join),
          ),
        ],
      ),
    );
  }
}
