part of 'journal_bloc.dart';

@immutable
sealed class JournalState {}

final class JournalInitial extends JournalState {}

final class JournalLoading extends JournalState {}

final class JournalFailure extends JournalState {
  final String error;
  JournalFailure(this.error);
}

final class JournalUploadSuccess extends JournalState {}

final class JournalGetterSuccess extends JournalState {
  final Map<String, Map<String, String>> allJournalEntries;
  JournalGetterSuccess(this.allJournalEntries);
}
