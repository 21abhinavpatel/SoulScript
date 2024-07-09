import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:soulscript/core/failures.dart';
import 'package:soulscript/core/usecase.dart';
import 'package:soulscript/journal/domain/journal_repository.dart';

class UploadJournalEntry
    implements
        UseCase<Map<String, Map<String, String>>, UploadJournalEntryParams> {
  final JournalRepository journalRepository;
  UploadJournalEntry(this.journalRepository);

  @override
  Future<Either<Failure, Map<String, Map<String, String>>>> call(
      UploadJournalEntryParams params) async {
    return await journalRepository.uploadJournalEntry(
      dateId: params.dateId,
      image: params.image,
      content: params.content,
    );
  }
}

class UploadJournalEntryParams {
  final String dateId;
  final String content;
  final File? image;

  UploadJournalEntryParams({
    required this.dateId,
    required this.content,
    this.image,
  });
}

class JournalGetter
    implements UseCase<Map<String, Map<String, String>>, NoParameters> {
  final JournalRepository journalRepository;
  JournalGetter(this.journalRepository);

  @override
  Future<Either<Failure, Map<String, Map<String, String>>>> call(
      NoParameters parameters) async {
    return await journalRepository.journalGetter();
  }
}

class JournalGetterStream
    implements StreamUseCase<Map<String, Map<String, String>>, NoParameters> {
  final JournalRepository journalRepository;
  JournalGetterStream(this.journalRepository);

  @override
  Stream<Either<Failure, Map<String, Map<String, String>>>> call(
      NoParameters parameters) async* {
    yield* journalRepository.journalGetterStream();
  }
}
