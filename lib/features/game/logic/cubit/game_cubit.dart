import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/room_model.dart';
import '../../../../core/utils/helpers.dart';
import '../../data/repositories/game_repository.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit({
    required this._gameRepository,
    required RoomModel room,
    required this._currentUserId,
  })  : _room = room,
        super(const GameInitial()) {
    _watchGame();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  final GameRepository _gameRepository;
  final RoomModel _room;
  final String _currentUserId;
  StreamSubscription<GameModel?>? _gameSubscription;
  Timer? _ticker;
  bool _forfeiting = false;

  String get _playerSymbol =>
      _currentUserId == _room.creatorId ? 'X' : 'O';

  String get _opponentId =>
      _currentUserId == _room.creatorId
          ? (_room.opponentId ?? '')
          : _room.creatorId;

  void _watchGame() {
    emit(const GameLoading());
    _gameSubscription?.cancel();
    _gameSubscription =
        _gameRepository.watchGameByRoomId(_room.roomId).listen(
      (game) {
        if (game == null) {
          emit(const GameError('Game not found.'));
          return;
        }

        if (game.isFinished) {
          unawaited(_recordStatsIfNeeded(game));
          unawaited(_gameRepository.completeRoom(_room.roomId));
          final didWin = game.winner == _currentUserId;
          emit(GameFinished(
            game: game,
            didWin: didWin,
            isDraw: game.isDraw,
          ));
        } else {
          emit(GameActive(
            game: game,
            playerSymbol: _playerSymbol,
            isMyTurn: game.currentTurn == _currentUserId,
            remainingSeconds: Helpers.remainingTurnSeconds(game.turnStartTime),
          ));
        }
      },
      onError: (Object error) => emit(GameError(error.toString())),
    );
  }

  void _onTick() {
    final current = state;
    if (current is! GameActive) return;

    final remaining =
        Helpers.remainingTurnSeconds(current.game.turnStartTime);
    if (remaining != current.remainingSeconds) {
      emit(GameActive(
        game: current.game,
        playerSymbol: current.playerSymbol,
        isMyTurn: current.isMyTurn,
        remainingSeconds: remaining,
      ));
    }

    if (remaining <= 0) {
      unawaited(_forfeitTurnIfNeeded(current));
    }
  }

  Future<void> _forfeitTurnIfNeeded(GameActive current) async {
    if (_forfeiting || current.game.isFinished) return;
    _forfeiting = true;
    try {
      await _gameRepository.forfeitTurn(
        gameId: current.game.gameId,
        expectedTurnUid: current.game.currentTurn,
        nextPlayerId: current.game.currentTurn == _room.creatorId
            ? (_room.opponentId ?? '')
            : _room.creatorId,
      );
    } catch (_) {
    } finally {
      _forfeiting = false;
    }
  }

  Future<void> makeMove(int index) async {
    final currentState = state;
    if (currentState is! GameActive) return;
    if (!currentState.isMyTurn) return;

    try {
      await _gameRepository.makeMove(
        game: currentState.game,
        index: index,
        playerId: _currentUserId,
        symbol: _playerSymbol,
        nextPlayerId: _opponentId,
        creatorId: _room.creatorId,
        opponentId: _room.opponentId ?? '',
      );
    } catch (e) {
      emit(GameError(e.toString()));
      _watchGame();
    }
  }

  Future<void> leaveMatch() async {
    if (state is GameFinished) {
      await _gameRepository.completeRoom(_room.roomId);
    }
  }

  Future<void> _recordStatsIfNeeded(GameModel game) async {
    final opponentId = _room.opponentId;
    if (opponentId == null || opponentId.isEmpty) return;

    try {
      await _gameRepository.recordMatchStats(
        game: game,
        creatorId: _room.creatorId,
        opponentId: opponentId,
      );
    } catch (_) {
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _gameSubscription?.cancel();
    return super.close();
  }
}
