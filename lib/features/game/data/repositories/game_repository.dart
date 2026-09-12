import '../../../../core/models/game_model.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/helpers.dart';

class GameRepository {
  GameRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  Stream<GameModel?> watchGameByRoomId(String roomId) =>
      _firestoreService.watchGame(roomId);

  Future<GameModel?> getGameByRoomId(String roomId) =>
      _firestoreService.getGame(roomId);

  Future<void> makeMove({
    required GameModel game,
    required int index,
    required String playerId,
    required String symbol,
    required String nextPlayerId,
    required String creatorId,
    required String opponentId,
  }) async {
    if (game.board[index].isNotEmpty) {
      throw Exception('Cell is already occupied.');
    }
    if (game.currentTurn != playerId) {
      throw Exception('Not your turn.');
    }
    if (game.isFinished) {
      throw Exception('Game is already finished.');
    }

    final updatedBoard = List<String>.from(game.board);
    updatedBoard[index] = symbol;

    final winner = _checkWinner(updatedBoard, playerId);
    final isDraw = winner == null && Helpers.isBoardFull(updatedBoard);

    final updatedGame = game.copyWith(
      board: updatedBoard,
      winner: winner,
      isDraw: isDraw,
      currentTurn: winner == null && !isDraw ? nextPlayerId : game.currentTurn,
      turnStartTime: DateTime.now().millisecondsSinceEpoch,
    );

    await _firestoreService.updateGame(updatedGame);

    if (updatedGame.isFinished) {
      await recordMatchStats(
        game: updatedGame,
        creatorId: creatorId,
        opponentId: opponentId,
      );
      await _firestoreService.completeRoom(updatedGame.roomId);
    }
  }

  Future<void> completeRoom(String roomId) =>
      _firestoreService.completeRoom(roomId);

  Future<void> forfeitTurn({
    required String gameId,
    required String expectedTurnUid,
    required String nextPlayerId,
  }) {
    return _firestoreService.forfeitTurn(
      gameId: gameId,
      expectedTurnUid: expectedTurnUid,
      nextPlayerId: nextPlayerId,
    );
  }

  Future<void> recordMatchStats({
    required GameModel game,
    required String creatorId,
    required String opponentId,
  }) async {
    if (!game.isFinished || game.statsRecorded) return;
    if (opponentId.isEmpty) return;

    await _firestoreService.recordMatchStats(
      gameId: game.gameId,
      creatorId: creatorId,
      opponentId: opponentId,
      winnerId: game.winner,
      isDraw: game.isDraw,
    );
  }

  String? _checkWinner(List<String> board, String playerId) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];
      if (a.isNotEmpty && a == b && b == c) {
        return playerId;
      }
    }
    return null;
  }
}
