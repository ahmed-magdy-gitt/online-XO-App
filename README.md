<p align="center">
  <a href="https://git.io/typing-svg">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=28&pause=1000&color=00D8FF&center=true&vCenter=true&width=620&lines=Online+XO+%E2%80%94+Real-Time+Multiplayer;Flutter+%2B+BLoC%2FCubit+%2B+Clean+Architecture;Firebase+Firestore+%2B+Auth+%2B+Transactions" alt="Typing SVG" />
  </a>
</p>

<p align="center">
  <i>A scalable, reactive real-time multiplayer Tic-Tac-Toe mobile platform engineered with Flutter, BLoC/Cubit, and Firebase.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Architecture-Clean_Architecture-007396?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/State_Management-BLoC_%2F_Cubit-blueviolet?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Firebase-Firestore_%26_Auth-FFA000?style=for-the-badge&logo=firebase&logoColor=white"/>
</p>

---

## 🎮 Project Overview

**Online XO (Tic-Tac-Toe Arena)** is an enterprise-grade, real-time multiplayer mobile game developed using **Flutter**. Designed from the ground up following **Clean Architecture** principles and modular feature separation, it delivers an instant, competitive experience with zero-latency remote board updates.

The system handles complete user authentication lifecycles, matchmaking lobbies with public/private rooms, turn timers with auto-forfeit validation, and atomic player score synchronization.

---

## 🛠️ Tech Stack

<p align="left">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/flutter/flutter-original.svg" alt="flutter" width="40" height="40"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/dart/dart-original.svg" alt="dart" width="40" height="40"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/firebase/firebase-plain.svg" alt="firebase" width="40" height="40"/>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/android/android-original.svg" alt="android" width="40" height="40"/>
</p>

| Layer | Technologies |
| :--- | :--- |
| **Framework & Language** | Flutter (Cross-Platform), Dart |
| **Architecture** | Feature-Driven Clean Architecture (Presentation, Logic, Data/Repo, Services) |
| **State Management** | `flutter_bloc` / `cubit` with immutable states (`Equatable`) |
| **Backend & Real-Time Sync** | Firebase Cloud Firestore (Streams, Transactions) |
| **Authentication Engine** | Firebase Auth (Email & Password, Session Streams) |

---
## 📸 Screenshots

| Authentication | Rooms Lobby | Live Match | Player Profile |
| :---: | :---: | :---: | :---: |
| <img width="240" alt="Lobby & Matchmaking" src="https://github.com/user-attachments/assets/3d917d0e-7799-44d7-b5a6-5d0165f1c982" /> | <img width="240" alt="Login & Register Screen" src="https://github.com/user-attachments/assets/bf81f95a-b564-4cef-ae3b-ce51a1bc5132" /> | <img width="240" alt="Real-time Game Board" src="https://github.com/user-attachments/assets/c0dd144b-880c-4265-a436-a89901bb3365" /> | <img width="240" alt="Profile & Stats" src="https://github.com/user-attachments/assets/bde871dc-8fa5-4d88-8c6f-500596209a5d" /> |
> **Note:** لاستبدال الصور بصور حقيقية: اسحب صور الشاشات وضعها مباشرة (Drag & Drop) في نافذة تعديل الـ README على GitHub أو ارفعها في فولدر `assets/screenshots` واستبدل الروابط.
## 🏗️ Architecture & Project Structure

The project strictly separates concerns into independent domain, data, and presentation layers:

* 🌐 **`lib/core/services/`:** Direct wrappers for external SDKs (`FirebaseService`, `AuthService`, `FirestoreService`).
* 📦 **`lib/core/models/`:** Strongly typed data entities (`GameModel`, `RoomModel`, `UserModel`).
* ⚙️ **`lib/core/utils/`:** Business helpers, board validation, and input sanitization (`helpers.dart`, `validators.dart`, `app_dialogs.dart`).
* 🎯 **`lib/features/auth/`:** Authentication flows powered by `AuthCubit` and `AuthRepository`.
* 🎲 **`lib/features/game/`:** Core gameplay engine, 30s turn timer management, and real-time state streaming via `GameCubit`.
* 🏠 **`lib/features/home/` & `room/`:** Room discovery lobby, matchmaking, and player readiness synchronization.
* 👤 **`lib/features/profile/`:** Live calculation of wins, losses, win rates, and account management.

---

## ✨ Key Capabilities

* 🔐 **Firebase Authentication:** Account creation, credentials validation, and real-time session tracking (`authStateChanges`).
* ⚡ **Real-Time Board Sync:** Firestore Stream listeners ensuring real-time grid synchronization across two remote devices.
* ⏱️ **Enforced Turn Timers:** 30-second countdown logic per turn with automatic timeout handling.
* 🛡️ **Atomic Stats via Transactions:** Zero race conditions during score updates (Wins, Losses, Win Rates) using Firestore Transactions.
* 🚪 **Room Matchmaking:** Create public or password-protected rooms with dynamic player slots and auto-cleanup.
* 📊 **Live Player Stats:** Auto-computed win percentages (`formatWinRate`) and profile history tracking.

---

## 🚀 How to Run

### Prerequisites
* Flutter SDK (3.x or higher)
* Android Studio / VS Code
* Firebase project configured via FlutterFire CLI

### Local Setup
1. **Clone the repository:**
   ```bash
   git clone [https://github.com/ahmed-magdy-gitt/online-XO-App.git](https://github.com/ahmed-magdy-gitt/online-XO-App.git)
   cd online-XO-App
