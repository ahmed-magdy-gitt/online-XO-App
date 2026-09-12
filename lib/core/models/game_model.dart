import 'package:equatable/equatable.dart';

import '../utils/helpers.dart';

class GameModel extends Equatable {
  const GameModel({
    required this.gameId,
    required this.roomId,
    required this.board,
    required this.currentTurn,
    this.winner,
    this.isDraw = false,
    required this.turnStartTime,
    this.statsRecorded = false,
  });

  final String gameId;
  final String roomId;
  final List<String> board;
  final String currentTurn;
  final String? winner;
  final bool isDraw;
  final int turnStartTime;
  final bool statsRecorded;

  bool get isFinished => winner != null || isDraw;

  factory GameModel.fromMap(Map<String, dynamic> map) {
    final rawBoard = map['board'];
    final board = rawBoard is List
        ? rawBoard.map((e) => e?.toString() ?? '').toList()
        : Helpers.emptyBoard();

    while (board.length < 9) {
      board.add('');
    }

    return GameModel(
      gameId: map['gameId'] as String? ?? '',
      roomId: map['roomId'] as String? ?? '',
      board: board.take(9).toList(),
      currentTurn: map['currentTurn'] as String? ?? '',
      winner: map['winner'] as String?,
      isDraw: map['isDraw'] as bool? ?? false,
      turnStartTime: (map['turnStartTime'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      statsRecorded: map['statsRecorded'] as bool? ?? false,
    );
  }

  factory GameModel.initial({
    required String gameId,
    required String roomId,
    required String startingPlayerId,
  }) {
    return GameModel(
      gameId: gameId,
      roomId: roomId,
      board: Helpers.emptyBoard(),
      currentTurn: startingPlayerId,
      turnStartTime: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'roomId': roomId,
      'board': board,
      'currentTurn': currentTurn,
      'winner': winner,
      'isDraw': isDraw,
      'turnStartTime': turnStartTime,
      'statsRecorded': statsRecorded,
    };
  }

  GameModel copyWith({
    String? gameId,
    String? roomId,
    List<String>? board,
    String? currentTurn,
    String? winner,
    bool? isDraw,
    int? turnStartTime,
    bool? statsRecorded,
    bool clearWinner = false,
  }) {
    return GameModel(
      gameId: gameId ?? this.gameId,
      roomId: roomId ?? this.roomId,
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      winner: clearWinner ? null : (winner ?? this.winner),
      isDraw: isDraw ?? this.isDraw,
      turnStartTime: turnStartTime ?? this.turnStartTime,
      statsRecorded: statsRecorded ?? this.statsRecorded,
    );
  }

  @override
  List<Object?> get props => [
        gameId,
        roomId,
        board,
        currentTurn,
        winner,
        isDraw,
        turnStartTime,
        statsRecorded,
      ];
}
