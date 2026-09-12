import 'package:firebase_auth/firebase_auth.dart';

abstract final class Helpers {
  static String mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  static String formatWinRate(int wins, int losses, int draws) {
    final total = wins + losses + draws;
    if (total == 0) return '0%';
    return '${((wins / total) * 100).toStringAsFixed(1)}%';
  }

  static List<String> emptyBoard() => List.filled(9, '');

  static bool isBoardFull(List<String> board) =>
      board.every((cell) => cell.isNotEmpty);

  static const int turnDurationSeconds = 30;

  static int remainingTurnSeconds(int turnStartTime) {
    final elapsedMs =
        DateTime.now().millisecondsSinceEpoch - turnStartTime;
    final remaining = turnDurationSeconds - (elapsedMs / 1000).floor();
    return remaining < 0 ? 0 : remaining;
  }
}
