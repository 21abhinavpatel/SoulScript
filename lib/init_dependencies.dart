import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:soulscript/core/app_secrets.dart';
import 'package:soulscript/core/connection_checker.dart';
import 'package:soulscript/journal/data/journal_local_data_source.dart';
import 'package:soulscript/journal/data/journal_remote_data_source.dart';
import 'package:soulscript/journal/data/journal_repository_impl.dart';
import 'package:soulscript/journal/domain/journal_repository.dart';
import 'package:soulscript/journal/domain/usecases.dart';
import 'package:soulscript/journal/presentation/bloc/journal_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initHive();
  _initJournal();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerFactory(() => InternetConnection());

  //Core
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImplementation(
      serviceLocator(),
    ),
  );
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  var journalBox = await Hive.openBox('journal');
  serviceLocator.registerLazySingleton(() => journalBox);
  serviceLocator.registerLazySingleton<HiveInterface>(() => Hive);
}

void _initJournal() {
  serviceLocator
    // Datasource
    ..registerFactory<JournalRemoteDataSource>(
      () => JournalRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<JournalLocalDataSource>(
      () => JournalLocalDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<JournalRepository>(
      () => JournalRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Usecase
    ..registerFactory(
      () => UploadJournalEntry(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => JournalGetter(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => JournalGetterStream(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => JournalBloc(
        uploadJournalEntry: serviceLocator(),
        journalGetter: serviceLocator(),
        journalGetterStream: serviceLocator(),
      ),
    );
}
