# 📝 Adaptive Flutter Todo Application

A feature-rich, cross-platform **Todo Dashboard Application** built with **Flutter** and **Dart**. Designed to help users stay organized with local data persistence, interactive analytics, and customizable task management.

---

## 🌟 Features

* 💾 **Local Data Persistence:** Tasks are stored locally using an embedded **SQLite (`sqflite`)** database, ensuring data remains intact across app restarts.
* 🔔 **Scheduled Local Notifications:** Integrated `flutter_local_notifications` to alert users when scheduled tasks are due.
* 🔍 **Real-Time Search & Filtering:** Filter tasks instantly by typing in the search bar, or filter by category and status (*All*, *Pending*, *Completed*).
* 👆 **Gesture Controls (Swipe Actions):** 
  * Swipe **Right** to toggle task completion.
  * Swipe **Left** to delete a task.
* 📊 **Analytics & Insights:** Interactive visual charts powered by `fl_chart` to track completion rates and weekly productivity trends.
* 🌗 **Adaptive Dynamic Dark/Light Theme:** Built with Material 3 styling and customizable theme toggling.
* ✏️ **Full CRUD Capabilities:** Easily create, edit, update, and delete tasks with dynamic bottom modal sheets.

---

## 🛠️ Tech Stack & Architecture

* **Framework:** [Flutter](https://flutter.dev/) (Dart SDK)
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Local Database:** [sqflite](https://pub.dev/packages/sqflite)
* **Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
* **UI & Charts:** [fl_chart](https://pub.dev/packages/fl_chart) & Material 3

---

## 📁 Project Structure

```text
lib/
├── models/          # Data structures (Todo model & categories)
├── providers/       # State management (TodoProvider, ThemeProvider)
├── screens/         # Application views (HomeScreen, AnalyticsScreen, SettingsScreen)
├── services/        # Backend helpers (DatabaseService, NotificationService)
└── widgets/         # Modular UI components (TodoTile)