import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:soulscript/core/failures.dart';
import 'package:soulscript/core/usecase.dart';
import 'package:soulscript/journal/domain/usecases.dart';
part 'journal_event.dart';
part 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final UploadJournalEntry _uploadJournalEntry;
  final JournalGetter _journalGetter;
  final JournalGetterStream _journalGetterStream;
  JournalBloc({
    required UploadJournalEntry uploadJournalEntry,
    required JournalGetter journalGetter,
    required JournalGetterStream journalGetterStream,
  })  : _uploadJournalEntry = uploadJournalEntry,
        _journalGetter = journalGetter,
        _journalGetterStream = journalGetterStream,
        super(JournalInitial()) {
    on<JournalEvent>((event, emit) => emit(JournalLoading()));
    on<UploadJournalEntryEvent>(_onJournalEntryUpload);
    on<JournalGetterEvent>(_onJournalGetter);
    on<JournalGetterStreamEvent>(_onJournalGetterStream);
  }

  void _onJournalEntryUpload(
    UploadJournalEntryEvent event,
    Emitter<JournalState> emit,
  ) async {
    final response = await _uploadJournalEntry(UploadJournalEntryParams(
      dateId: event.dateId,
      content: event.content,
      image: event.image,
    ));
    response.fold(
      (l) => emit(JournalFailure(l.message)),
      (r) => emit(
        JournalUploadSuccess(),
      ),
    );
  }

  void _onJournalGetter(
    JournalGetterEvent event,
    Emitter<JournalState> emit,
  ) async {
    final response = await _journalGetter(NoParameters());
    response.fold(
      (l) => emit(JournalFailure(l.message)),
      (r) => emit(JournalGetterSuccess(r)),
    );
  }

  void _onJournalGetterStream(
    JournalGetterStreamEvent event,
    Emitter<JournalState> emit,
  ) async {
    final response = _journalGetterStream(NoParameters());

    await for (var combine in Rx.combineLatest(
      [response],
      (values) {
        final allJournalEntriesResult = values[0];
        return JournalData(
          allJournalEntriesResult: allJournalEntriesResult,
        );
      },
    )) {
      combine.allJournalEntriesResult.fold(
        (failure) => emit(JournalFailure(failure.message)),
        (allJournalEntries) =>
            emit(JournalGetterSuccess(allJournalEntries)),
      );
    }
  }
}

class JournalData {
  final Either<Failure, Map<String, Map<String, String>>>
      allJournalEntriesResult;

  JournalData({
    required this.allJournalEntriesResult,
  });
}
