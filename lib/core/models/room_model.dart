import 'package:equatable/equatable.dart';

enum RoomStatus {
  waiting('waiting'),
  playing('playing'),
  completed('completed'),
  cancelled('cancelled');

  const RoomStatus(this.value);

  final String value;

  static RoomStatus fromString(String? value) {
    switch (value) {
      case 'waiting':
        return RoomStatus.waiting;
      case 'playing':
      case 'in_progress':
        return RoomStatus.playing;
      case 'completed':
      case 'finished':
        return RoomStatus.completed;
      case 'cancelled':
      case 'abandoned':
      case 'closed':
        return RoomStatus.cancelled;
      default:
        return RoomStatus.cancelled;
    }
  }
}

class RoomModel extends Equatable {
  const RoomModel({
    required this.roomId,
    required this.creatorId,
    required this.creatorName,
    this.opponentId,
    this.opponentName,
    this.status = RoomStatus.waiting,
    this.gameStarted = false,
    required this.createdAt,
  });

  final String roomId;
  final String creatorId;
  final String creatorName;
  final String? opponentId;
  final String? opponentName;
  final RoomStatus status;
  final bool gameStarted;
  final DateTime createdAt;

  String get hostId => creatorId;
  String? get guestId => opponentId;

  bool get isFull => guestId != null && guestId!.isNotEmpty;
  bool get isWaiting =>status == RoomStatus.waiting && !isFull && !gameStarted;
  bool get isInLobby => !gameStarted && !isCompleted && !isCancelled;
  bool get isPlaying => status == RoomStatus.playing || gameStarted;
  bool get isCompleted => status == RoomStatus.completed;
  bool get isCancelled => status == RoomStatus.cancelled;
  bool get isJoinable => isWaiting;
  bool get canStartGame => isFull && !gameStarted && !isCancelled && !isCompleted;

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    final guestId = (map['guestId'] as String?) ?? (map['opponentId'] as String?);
    final guestName =
        (map['guestName'] as String?) ?? (map['opponentName'] as String?);
    final hostId = (map['hostId'] as String?) ?? (map['creatorId'] as String?);

    return RoomModel(
      roomId: map['roomId'] as String? ?? '',
      creatorId: hostId ?? '',
      creatorName: map['creatorName'] as String? ??
          map['hostName'] as String? ??
          '',
      opponentId: (guestId != null && guestId.isNotEmpty) ? guestId : null,
      opponentName:
          (guestName != null && guestName.isNotEmpty) ? guestName : null,
      status: RoomStatus.fromString(map['status'] as String?),
      gameStarted: map['gameStarted'] as bool? ?? false,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'hostId': creatorId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'hostName': creatorName,
      'guestId': opponentId,
      'guestName': opponentName,
      'opponentId': opponentId,
      'opponentName': opponentName,
      'status': status.value,
      'gameStarted': gameStarted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  RoomModel copyWith({
    String? roomId,
    String? creatorId,
    String? creatorName,
    String? opponentId,
    String? opponentName,
    RoomStatus? status,
    bool? gameStarted,
    DateTime? createdAt,
    bool clearOpponent = false,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      opponentId: clearOpponent ? null : (opponentId ?? this.opponentId),
      opponentName: clearOpponent ? null : (opponentName ?? this.opponentName),
      status: status ?? this.status,
      gameStarted: gameStarted ?? this.gameStarted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  @override
  List<Object?> get props => [
        roomId,
        creatorId,
        creatorName,
        opponentId,
        opponentName,
        status,
        gameStarted,
        createdAt,
      ];
}
