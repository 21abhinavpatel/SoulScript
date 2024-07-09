import 'dart:io';
import 'package:soulscript/core/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class JournalRemoteDataSource {
  Future<Map<String, Map<String, String>>> uploadJournalEntry(
    String dateId,
    String content,
    String imageUrl,
  );
  Future<String> uploadJournalImage({
    required String dateId,
    required File image,
  });
  Future<Map<String, Map<String, String>>> journalGetter();
}

class JournalRemoteDataSourceImpl implements JournalRemoteDataSource {
  final SupabaseClient supabaseClient;
  JournalRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<Map<String, Map<String, String>>> uploadJournalEntry(
    String dateId,
    String content,
    String imageUrl,
  ) async {
    try {
      final allJournalEntriesResponse = await supabaseClient
          .from('journal')
          .select('all_journal_entries')
          .eq('id', 1)
          .single();
      final allJournalEntries = Map<String, Map<String, String>>.from(
          (allJournalEntriesResponse['all_journal_entries']
                      as Map<String, dynamic>? ??
                  {})
              .map((key, value) =>
                  MapEntry(key, Map<String, String>.from(value))));
      Map<String, String> newJournalEntry = {};
      newJournalEntry['c'] = content;
      newJournalEntry['i'] = imageUrl;
      allJournalEntries[dateId] = newJournalEntry;
      final uploadedJournalResponse = await supabaseClient
          .from('journal2')
          .update({'all_journal_entries': allJournalEntries})
          .eq('id', 1)
          .select()
          .single();
      return Map<String, Map<String, String>>.from((uploadedJournalResponse[
                  'all_journal_entries'] as Map<String, dynamic>? ??
              {})
          .map((key, value) => MapEntry(key, Map<String, String>.from(value))));
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadJournalImage({
    required String dateId,
    required File image,
  }) async {
    try {
      await supabaseClient.storage.from('journal_images').upload(
            dateId,
            image,
          );
      return supabaseClient.storage.from('journal_images').getPublicUrl(dateId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, Map<String, String>>> journalGetter() async {
    try {
      final allJournalEntriesResponse = await supabaseClient
          .from('journal')
          .select('all_journal_entries')
          .eq('id', 1)
          .single();
      return Map<String, Map<String, String>>.from(
          (allJournalEntriesResponse['all_journal_entries']
                      as Map<String, dynamic>? ??
                  {})
              .map((key, value) =>
                  MapEntry(key, Map<String, String>.from(value))));
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
