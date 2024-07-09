import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:soulscript/core/failures.dart';

abstract interface class JournalRepository {
  Future<Either<Failure, Map<String, Map<String, String>>>> uploadJournalEntry({
    required String dateId,
    required String content,
    required File? image,
  });
  Future<Either<Failure, Map<String, Map<String, String>>>> journalGetter();
}
