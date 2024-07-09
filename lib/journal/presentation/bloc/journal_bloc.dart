import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulscript/core/usecase.dart';
import 'package:soulscript/journal/domain/usecases.dart';
part 'journal_event.dart';
part 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final UploadJournalEntry _uploadJournalEntry;
  final JournalGetter _journalGetter;
  JournalBloc({
    required UploadJournalEntry uploadJournalEntry,
    required JournalGetter journalGetter,
  })  : _uploadJournalEntry = uploadJournalEntry,
        _journalGetter = journalGetter,
        super(JournalInitial()) {
    on<JournalEvent>((event, emit) => emit(JournalLoading()));
    on<UploadJournalEntryEvent>(_onJournalEntryUpload);
    on<JournalGetterEvent>(_onJournalGetter);
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
}
