import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/journal_entry.dart';
import 'storage/journal_storage.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with the Flutter app directory
  await Hive.initFlutter();

  // Register the generated TypeAdapter so Hive knows how to read/write JournalEntry
  Hive.registerAdapter(JournalEntryAdapter());

  // Open the journal entries box — must happen before any screen reads from it
  await JournalStorage.init();

  runApp(const MindTrackApp());
}
