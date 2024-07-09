import 'package:hive/hive.dart';

abstract interface class JournalLocalDataSource {
  Future<void> saveDateIdList({required Map<String, String> dateIdList});
  Map<String, String>? loadDateIdList();
  Future<void> saveAllJournalEntries(
      {required Map<String, Map<String, String>> allJournalEntries});
  Map<String, Map<String, String>>? loadAllJournalEntries();
}

class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  final Box box;
  JournalLocalDataSourceImpl(this.box);

  @override
  Future<void> saveDateIdList({required Map<String, String> dateIdList}) async {
    await box.delete('dateIdList');
    await box.put('dateIdList', dateIdList);
  }

  @override
  Map<String, String>? loadDateIdList() {
    final json = box.get('dateIdList');
    if (json != null) {
      return json;
    }
    return null;
  }

  @override
  Future<void> saveAllJournalEntries(
      {required Map<String, Map<String, String>> allJournalEntries}) async {
    await box.delete('allJournalEntries');
    await box.put('allJournalEntries', allJournalEntries);
  }

  @override
  Map<String, Map<String, String>>? loadAllJournalEntries() {
    final json = box.get('allJournalEntries');
    if (json != null) {
      var resultMap = <String, Map<String, String>>{};
      json.forEach((key, value) {
        resultMap[key] = Map<String, String>.from(value);
      });
      return resultMap;
    }
    return null;
  }
}
