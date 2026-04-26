---

# 🧠 MindTrack – AI Mood Journal App

A modern Flutter journaling app that helps users track their daily emotions and gain AI-powered emotional insights.

Built with **Flutter, Cubit (BLoC), Hive, and OpenAI API**, MindTrack demonstrates a clean architecture approach combined with real AI integration.

---

## ✨ Features

### 📝 Smart Journaling

* Create daily journal entries
* Select mood using an intuitive mood selector
* Store entries locally using Hive (offline-first)

### 😊 Mood Tracking

* Visual mood system (Rough → Great)
* Weekly mood overview strip
* Mood history per entry

### 🤖 AI-Powered Insights

* Analyze journal text using OpenAI GPT-4o-mini
* Get:

  * Detected mood (0–4 scale)
  * Emotional label (Good, Low, etc.)
  * Short empathetic insight
  * Confidence score

### 📊 Smart UI Enhancements

* AI suggestion card inside journal creation
* Auto mood detection from AI
* Clean, minimal and modern UI design

---

## 🧱 Architecture

MindTrack follows a clean layered architecture:

```
UI → Cubit → Repository → Storage (Hive)
                 ↓
             AI Service → OpenAI API
```

### Layers:

* **UI Layer** → Flutter Screens & Widgets
* **Cubit Layer** → State management (flutter_bloc)
* **Repository Layer** → Business logic abstraction
* **Storage Layer** → Hive local database
* **Service Layer** → OpenAI API integration

---

## 📦 Tech Stack

* Flutter
* Dart
* flutter_bloc (Cubit)
* Hive (Local Storage)
* OpenAI API (GPT-4o-mini)
* flutter_dotenv (Environment variables)
* HTTP package

---

## 🧠 AI Feature Details

The AI analyzes journal entries using the following structure:

### Input:

User journal text

### Output (JSON):

```json
{
  "moodIndex": 3,
  "label": "Good",
  "confidence": 0.87,
  "insight": "You seem calm and productive today"
}
```

---

## 🔐 Security

* API keys are stored in `.env`
* `.env` is excluded from version control
* No secrets are hardcoded in source code
* Uses environment-based configuration via `flutter_dotenv`

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/mindtrack.git
cd mindtrack
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Add environment file

Create a `.env` file in root:

```env
OPENAI_API_KEY=your_api_key_here
```

### 4. Run the app

```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
 ├── cubit/
 ├── models/
 ├── repositories/
 ├── storage/
 ├── services/
 ├── screens/
 ├── widgets/
 └── main.dart
```

---

## 🎯 Purpose of This Project

This project was built to demonstrate:

* Clean Architecture in Flutter
* State management with Cubit
* Real-world API integration
* Local storage with Hive
* AI-powered feature integration
* Production-level project structure

---

## 💡 Future Improvements

* AI Daily Summary of user mood
* Mood analytics dashboard
* Cloud sync (Firebase)
* Authentication system
* Push notifications for journaling reminders

---

## 👩‍💻 Author

Built with ❤️ using Flutter & AI


