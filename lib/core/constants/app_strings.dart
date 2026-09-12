abstract final class AppStrings {
  static const String appName = 'EXOmania';
  static const String appTagline = 'Real-Time Multiplayer Tic-Tac-Toe';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Display Name';
  static const String confirmPassword = 'Confirm Password';
  static const String noAccount = "Don't have an account? Register";
  static const String hasAccount = 'Already have an account? Login';
  static const String welcomeBack = 'Welcome Back';
  static const String createAccount = 'Create Account';

  // Home
  static const String home = 'Home';
  static const String createRoom = 'Create Room';
  static const String joinRoom = 'Join Room';
  static const String quickPlay = 'Quick Play';
  static const String profile = 'Profile';

  // Room
  static const String waitingForOpponent = 'Waiting for opponent...';
  static const String roomCode = 'Room Code';
  static const String join = 'Join';
  static const String cancel = 'Cancel';
  static const String yourRoomWaiting = 'Your Room - Waiting';
  static const String openRooms = 'Open Rooms';
  static const String roomUnavailable = 'This room is no longer available.';
  static const String startGame = 'Start Game';
  static const String kickPlayer = 'Kick Player';
  static const String leaveRoom = 'Leave Room';
  static const String player1 = 'Player 1 (Host)';
  static const String player2 = 'Player 2 (Guest)';
  static const String waitingForHostToStart = 'Waiting for host to start...';
  static const String kickedFromRoom = 'You were removed from the room.';

  // Game
  static const String yourTurn = 'Your Turn';
  static const String opponentTurn = "Opponent's Turn";
  static const String youWin = 'You Win!';
  static const String youLose = 'You Lose!';
  static const String draw = "It's a Draw!";
  static const String playAgain = 'Play Again';
  static const String leaveGame = 'Leave Game';

  // Profile
  static const String wins = 'Wins';
  static const String losses = 'Losses';
  static const String draws = 'Draws';
  static const String stats = 'Statistics';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network error. Check your connection.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String invalidPassword = 'Password must be at least 6 characters.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String nameRequired = 'Display name is required.';
}
