import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:soulscript/core/connection_checker.dart';
import 'package:soulscript/core/exceptions.dart';
import 'package:soulscript/core/failures.dart';
import 'package:soulscript/journal/data/journal_local_data_source.dart';
import 'package:soulscript/journal/data/journal_remote_data_source.dart';
import 'package:soulscript/journal/domain/journal_repository.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalRemoteDataSource journalRemoteDataSource;
  final JournalLocalDataSource journalLocalDataSource;
  final ConnectionChecker connectionChecker;
  JournalRepositoryImpl(this.journalRemoteDataSource,
      this.journalLocalDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, Map<String, Map<String, String>>>> uploadJournalEntry({
    required String dateId,
    required String content,
    required File? image,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure('No internet connection!'));
      }
      String imageUrl = '';
      if (image != null) {
        imageUrl = await journalRemoteDataSource.uploadJournalImage(
          dateId: dateId,
          image: image,
        );
      }
      final uploadedJournal =
          await journalRemoteDataSource.uploadJournalEntry(dateId, content, imageUrl);
      return right(uploadedJournal);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, Map<String, String>>>> journalGetter() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final allJournalEntries =
            journalLocalDataSource.loadAllJournalEntries();
        return right(allJournalEntries!);
      }
      final allJournalEntries =
            await journalRemoteDataSource.journalGetter();
      await journalLocalDataSource.saveAllJournalEntries(
          allJournalEntries: allJournalEntries);
      return right(allJournalEntries);
    } on ServerException catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
