# 🎮 Tic-Tac-Toe Arena (Real-Time Multiplayer)

A scalable, real-time multiplayer Tic-Tac-Toe game developed with **Flutter** and backed by **Firebase Cloud Firestore** & **Firebase Auth**. Engineered following **Clean Architecture** principles and utilizing the **BLoC/Cubit** pattern for reactive state management.

---

## 🚀 Key Features

* **Authentication:** Secure user sign-up, login, and profile tracking using Firebase Auth.
* **Real-time Matchmaking:** Create, join, and list public/private rooms via Firestore streams.
* **Live Gameplay:** Real-time board state synchronization between two remote players.
* **Atomic Stats & Transactions:** Zero-race-condition score keeping (Wins, Losses, Win Rate) powered by Firestore Transactions.
* **Turn Timer Enforcement:** 30-second turn timeout with automatic forfeit logic.
* **Player Profiles:** Real-time live updates of match history and statistics.

---

## 🏗️ Architecture & Tech Stack

* **Framework:** Flutter (Dart)
* **Architecture:** Clean Architecture (Core, Features, Logic, Presentation, Data/Repositories, Services)
* **State Management:** `flutter_bloc` / `cubit` with `equatable`
* **Backend & Database:** Firebase Authentication & Cloud Firestore (NoSQL)
* **Code Style:** Strict linting, layered separation of concerns, and robust error handling.
