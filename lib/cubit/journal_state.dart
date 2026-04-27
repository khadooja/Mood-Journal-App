import '../models/journal_entry.dart';
import 'package:equatable/equatable.dart';

/// All possible states the journal feature can be in.
/// The UI will rebuild only when the state instance changes.
abstract class JournalState extends Equatable {
  const JournalState();

  @override
  List<Object?> get props => [];
}

/// App just launched — nothing has been loaded yet.
class JournalInitial extends JournalState {
  const JournalInitial();
}

/// Async operation in progress (loading or saving).
class JournalLoading extends JournalState {
  const JournalLoading();
}

/// Entries loaded successfully. This is the normal display state.
class JournalLoaded extends JournalState {
  final List<JournalEntry> entries;

  const JournalLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

/// Something went wrong. Carries a human-readable message.
class JournalError extends JournalState {
  final String message;

  const JournalError(this.message);

  @override
  List<Object?> get props => [message];
}