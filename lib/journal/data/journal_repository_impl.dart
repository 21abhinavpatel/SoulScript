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
      String localUrl = '';
      if (image != null) {
        imageUrl = await journalRemoteDataSource.uploadJournalImage(
          dateId: dateId,
          image: image,
        );
        localUrl = await journalLocalDataSource.saveImage(
            image: image, dateId: dateId);
      }
      final uploadedJournal = await journalRemoteDataSource.uploadJournalEntry(
          dateId, content, imageUrl, localUrl);
      return right(uploadedJournal);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, Map<String, String>>>>
      journalGetter() async {
    try {
      final allJournalEntries = await journalRemoteDataSource.journalGetter();
      return right(allJournalEntries);
    } on ServerException catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Map<String, Map<String, String>>>>
      journalGetterStream() async* {
    try {
      final localJournalEntries =
          journalLocalDataSource.loadAllJournalEntries();
      yield Right(localJournalEntries);
      if (await connectionChecker.isConnected) {
        final remoteJournalEntries =
            await journalRemoteDataSource.journalGetter();
        // final remoteDateIdSet = remoteJournalEntries.keys.toSet();
        // Set<String> dateIdSet = remoteDateIdSet;
        // if (localJournalEntries.isNotEmpty) {
        //   dateIdSet =
        //       remoteDateIdSet.difference(localJournalEntries.keys.toSet());
        // }
        // print(dateIdSet);
        // if (dateIdSet.isNotEmpty) {
        //   for (var dateId in dateIdSet) {
        //   }
        //   await journalLocalDataSource.saveAllJournalEntries(
        //       allJournalEntries: remoteJournalEntries);
        // }
        // final newLocalJournalEntries =
        //     journalLocalDataSource.loadAllJournalEntries();
        await journalLocalDataSource.saveAllJournalEntries(
            allJournalEntries: remoteJournalEntries);
        yield Right(remoteJournalEntries);
      }
    } on ServerException catch (e) {
      yield Left(Failure(e.toString()));
    }
  }
}
