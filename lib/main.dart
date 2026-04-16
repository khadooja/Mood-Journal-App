import 'cubit/journal_cubit.dart';
import 'screens/home_screen.dart';
import 'models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'repositories/journal_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());
  await Hive.openBox<JournalEntry>('journalBox');

  runApp(const MindTrackApp());
}

class MindTrackApp extends StatelessWidget {
  const MindTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ..loadEntries() triggers the first load immediately on app start
      create: (_) => JournalCubit(repository: JournalRepository())
        ..loadEntries(),
      child: MaterialApp(
        title: 'MindTrack',
        home: const HomeScreen(),
      ),
    );
  }
}