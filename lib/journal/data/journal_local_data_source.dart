import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class JournalLocalDataSource {
  Future<String> saveImage({required File image, required String dateId});
  Future<void> saveDateIdSet({required Set<String> dateIdSet});
  Set<String>? loadDateIdSet();
  Future<void> saveAllJournalEntries(
      {required Map<String, Map<String, String>> allJournalEntries});
  Map<String, Map<String, String>> loadAllJournalEntries();
}

class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  final Box box;
  JournalLocalDataSourceImpl(this.box);

  @override
  Future<String> saveImage(
      {required File image, required String dateId}) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName = '$dateId.png';
    final file = File('$path/$fileName');
    await file.writeAsBytes(await image.readAsBytes());
    return file.path;
  }

  @override
  Future<void> saveDateIdSet({required Set<String> dateIdSet}) async {
    await box.delete('dateIdSet');
    await box.put('dateIdSet', dateIdSet);
  }

  @override
  Set<String>? loadDateIdSet() {
    final json = box.get('dateIdSet');
    if (json != null) {
      var list = json as List<dynamic>;
      return Set<String>.from(list);
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
  Map<String, Map<String, String>> loadAllJournalEntries() {
    final json = box.get('allJournalEntries');
    if (json != null) {
      var resultMap = <String, Map<String, String>>{};
      json.forEach((key, value) {
        resultMap[key] = Map<String, String>.from(value);
      });
      return resultMap;
    }
    return {};
  }
}
