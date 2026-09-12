import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/room_model.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../logic/cubit/game_cubit.dart';
import '../../logic/cubit/game_state.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.room});

  final RoomModel room;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return BlocProvider(
      create: (context) => GameCubit(
        gameRepository: context.read(),
        room: room,
        currentUserId: authState.user.uid,
      ),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameState>(
      listener: (context, state) {
        if (state is GameError) {
          AppDialogs.showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game'),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await context.read<GameCubit>().leaveMatch();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            if (state is GameLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GameActive || state is GameFinished) {
              final game = state is GameActive ? state.game : (state as GameFinished).game;
              final isMyTurn = state is GameActive && state.isMyTurn;
              final playerSymbol =
                  state is GameActive ? state.playerSymbol : '';

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _StatusBanner(state: state),
                    if (state is GameActive) ...[
                      const SizedBox(height: 16),
                      _TurnTimer(seconds: state.remainingSeconds),
                    ],
                    const SizedBox(height: 24),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            final cell = game.board[index];
                            final isX = cell == 'X';
                            final isO = cell == 'O';

                            return InkWell(
                              onTap: isMyTurn && cell.isEmpty
                                  ? () => context
                                      .read<GameCubit>()
                                      .makeMove(index)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.boardLine,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    cell,
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: isX
                                          ? AppColors.playerX
                                          : isO
                                              ? AppColors.playerO
                                              : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state is GameActive)
                      Text(
                        isMyTurn
                            ? AppStrings.yourTurn
                            : AppStrings.opponentTurn,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    if (state is GameActive)
                      Text('You are playing as $playerSymbol'),
                    if (state is GameFinished) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<GameCubit>().leaveMatch();
                          if (context.mounted) {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        },
                        child: const Text(AppStrings.leaveGame),
                      ),
                    ],
                  ],
                ),
              );
            }

            return const Center(child: Text('Loading game...'));
          },
        ),
      ),
    );
  }
}

class _TurnTimer extends StatelessWidget {
  const _TurnTimer({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 5;
    return Column(
      children: [
        Text(
          '${seconds}s',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: urgent ? AppColors.error : AppColors.secondary,
              ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: seconds / Helpers.turnDurationSeconds,
            minHeight: 8,
            color: urgent ? AppColors.error : AppColors.secondary,
            backgroundColor: AppColors.boardLine,
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    if (state is GameFinished) {
      final finished = state as GameFinished;
      final message = finished.isDraw
          ? AppStrings.draw
          : finished.didWin
              ? AppStrings.youWin
              : AppStrings.youLose;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: finished.didWin
              ? AppColors.success.withValues(alpha: 0.2)
              : finished.isDraw
                  ? AppColors.warning.withValues(alpha: 0.2)
                  : AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
