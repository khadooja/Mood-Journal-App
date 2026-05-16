import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'cubit/journal_cubit.dart';
import 'models/journal_entry.dart';
import 'repositories/journal_repository.dart';
import 'services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    // ignore: avoid_print
    print('API KEY: ${dotenv.env['OPENAI_API_KEY']}');
  } catch (_) {
    debugPrint('⚠️ .env not found — running without API key');
  }

  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());
  await Hive.openBox<JournalEntry>('journal_entries');

  runApp(
    BlocProvider(
      create: (_) => JournalCubit(
        repository: JournalRepository(),
        aiService: AiService(),
      )..loadEntries(),
      child: const MindTrackApp(),
    ),
  );
}
