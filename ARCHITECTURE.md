# MindTrack – Architecture Overview

## 📱 Project Summary

MindTrack is a Flutter journaling app that allows users to track their mood and write daily reflections.

---

## 🧱 Architecture

The project follows a simple clean architecture:

UI → Cubit → Repository → Storage (Hive)

* UI: Screens and Widgets
* Cubit: Handles state management and business logic
* Repository: Acts as a bridge between Cubit and Storage
* Storage: Local persistence using Hive

---

## 📂 Folder Structure

lib/
├── models/
│   ├── journal_entry.dart
│   └── mood_option.dart
│
├── storage/
│   └── journal_storage.dart
│
├── repositories/
│   └── journal_repository.dart
│
├── cubit/
│   ├── journal_cubit.dart
│   └── journal_state.dart
│
├── screens/
│   ├── home_screen.dart
│   └── add_entry_screen.dart
│
├── widgets/ (planned)
│   ├── entry_tile.dart
│   └── mood_strip.dart
│
├── app.dart
└── main.dart

---

## ✅ Current Features

* Add journal entry with mood selection
* Save entries locally using Hive
* Display entries in HomeScreen
* State management using Cubit
* Clean separation of layers

---

## ⚠️ Important Rules

* Do NOT access Hive directly from UI
* Always go through Cubit → Repository → Storage
* Do NOT change UI design unless explicitly asked
* Use moodIndex instead of mood string

---

## 🚧 Planned Improvements

* Extract reusable UI widgets (entry_tile, mood_strip)
* Add swipe-to-delete
* Improve empty state UI
* Add AI-powered mood insights (next phase)

---

## 🤖 AI Integration (Next Step)

Plan:
UI → Cubit → AI Service → API

The AI feature will:

* Analyze journal text
* Return emotional insights
* Display results in UI

---

## 🧩 Notes for AI Assistant

* This project is already functional — do NOT rebuild from scratch
* Focus on extending existing structure
* Keep code clean and minimal
* Follow current architecture strictly
