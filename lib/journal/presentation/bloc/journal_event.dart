part of 'journal_bloc.dart';

@immutable
sealed class JournalEvent {}

final class UploadJournalEntryEvent extends JournalEvent {
  final String dateId;
  final String content;
  final File? image;

  UploadJournalEntryEvent({
    required this.dateId,
    required this.content,
    this.image,
  });
}

final class JournalGetterEvent extends JournalEvent {}

final class JournalGetterStreamEvent extends JournalEvent {}
