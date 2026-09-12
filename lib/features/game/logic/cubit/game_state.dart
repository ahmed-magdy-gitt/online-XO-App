import 'package:equatable/equatable.dart';

import '../../../../core/models/game_model.dart';

abstract class GameState extends Equatable {
  const GameState();
  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {
  const GameInitial();
}

class GameLoading extends GameState {
  const GameLoading();
}

class GameActive extends GameState {
  const GameActive({
    required this.game,
    required this.playerSymbol,
    required this.isMyTurn,
    required this.remainingSeconds,
  });
  final GameModel game;
  final String playerSymbol;
  final bool isMyTurn;
  final int remainingSeconds;
  @override
  List<Object?> get props => [game, playerSymbol, isMyTurn, remainingSeconds];
}

class GameFinished extends GameState {
  const GameFinished({
    required this.game,
    required this.didWin,
    required this.isDraw,
  });
  final GameModel game;
  final bool didWin;
  final bool isDraw;
  @override
  List<Object?> get props => [game, didWin, isDraw];
}

class GameError extends GameState {
  const GameError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
