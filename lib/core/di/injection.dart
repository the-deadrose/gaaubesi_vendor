import 'package:gaaubesi_vendor/core/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit(
  asExtension: false,
)
Future<void> configureDependencies() => init(getIt);
