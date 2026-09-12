import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.totalGames = 0,
    this.winRate = 0,
  });

  final String uid;
  final String name;
  final String email;
  final int wins;
  final int losses;
  final int draws;
  final int totalGames;
  final double winRate;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final wins = (map['wins'] as num?)?.toInt() ?? 0;
    final losses = (map['losses'] as num?)?.toInt() ?? 0;
    final draws = (map['draws'] as num?)?.toInt() ?? 0;
    final totalGames =
        (map['totalGames'] as num?)?.toInt() ?? (wins + losses + draws);
    final winRate = (map['winRate'] as num?)?.toDouble() ??
        (totalGames == 0 ? 0 : (wins / totalGames) * 100);

    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      wins: wins,
      losses: losses,
      draws: draws,
      totalGames: totalGames,
      winRate: winRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'totalGames': totalGames,
      'winRate': winRate,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? wins,
    int? losses,
    int? draws,
    int? totalGames,
    double? winRate,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      totalGames: totalGames ?? this.totalGames,
      winRate: winRate ?? this.winRate,
    );
  }

  @override
  List<Object?> get props =>
      [uid, name, email, wins, losses, draws, totalGames, winRate];
}
