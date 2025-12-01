// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:gaaubesi_vendor/core/di/register_module.dart' as _i769;
import 'package:gaaubesi_vendor/core/network/dio_client.dart' as _i619;
import 'package:gaaubesi_vendor/core/router/app_router.dart' as _i694;
import 'package:gaaubesi_vendor/core/services/secure_storage_service.dart'
    as _i14;
import 'package:gaaubesi_vendor/features/auth/data/datasources/auth_local_data_source.dart'
    as _i18;
import 'package:gaaubesi_vendor/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i311;
import 'package:gaaubesi_vendor/features/auth/data/repositories/auth_repository_impl.dart'
    as _i635;
import 'package:gaaubesi_vendor/features/auth/domain/repositories/auth_repository.dart'
    as _i40;
import 'package:gaaubesi_vendor/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i277;
import 'package:gaaubesi_vendor/features/auth/domain/usecases/login_usecase.dart'
    as _i634;
import 'package:gaaubesi_vendor/features/auth/domain/usecases/logout_usecase.dart'
    as _i357;
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart'
    as _i365;
import 'package:gaaubesi_vendor/features/home/data/datasources/home_remote_data_source.dart'
    as _i630;
import 'package:gaaubesi_vendor/features/home/data/repositories/home_repository_impl.dart'
    as _i990;
import 'package:gaaubesi_vendor/features/home/domain/repositories/home_repository.dart'
    as _i103;
import 'package:gaaubesi_vendor/features/home/domain/usecases/get_vendor_stats_usecase.dart'
    as _i84;
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_bloc.dart'
    as _i915;
import 'package:gaaubesi_vendor/features/orders/data/datasources/order_remote_data_source.dart'
    as _i700;
import 'package:gaaubesi_vendor/features/orders/data/repositories/order_repository_impl.dart'
    as _i800;
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart'
    as _i532;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_delivered_orders_usecase.dart'
    as _i451;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_orders_usecase.dart'
    as _i340;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order_bloc.dart'
    as _i853;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_bloc.dart'
    as _i238;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i694.AppRouter>(() => _i694.AppRouter());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i18.AuthLocalDataSource>(
      () => _i18.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i14.SecureStorageService>(
      () => _i14.SecureStorageServiceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i619.DioClient>(
      () => _i619.DioClient(gh<_i361.Dio>(), gh<_i14.SecureStorageService>()),
    );
    gh.lazySingleton<_i630.HomeRemoteDataSource>(
      () => _i630.HomeRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i103.HomeRepository>(
      () => _i990.HomeRepositoryImpl(gh<_i630.HomeRemoteDataSource>()),
    );
    gh.lazySingleton<_i700.OrderRemoteDataSource>(
      () => _i700.OrderRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i311.AuthRemoteDataSource>(
      () => _i311.AuthRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i84.GetVendorStatsUseCase>(
      () => _i84.GetVendorStatsUseCase(gh<_i103.HomeRepository>()),
    );
    gh.lazySingleton<_i40.AuthRepository>(
      () => _i635.AuthRepositoryImpl(
        remoteDataSource: gh<_i311.AuthRemoteDataSource>(),
        localDataSource: gh<_i18.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i532.OrderRepository>(
      () => _i800.OrderRepositoryImpl(
        remoteDataSource: gh<_i700.OrderRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i634.LoginUseCase>(
      () => _i634.LoginUseCase(gh<_i40.AuthRepository>()),
    );
    gh.lazySingleton<_i357.LogoutUseCase>(
      () => _i357.LogoutUseCase(gh<_i40.AuthRepository>()),
    );
    gh.lazySingleton<_i277.GetCurrentUserUseCase>(
      () => _i277.GetCurrentUserUseCase(gh<_i40.AuthRepository>()),
    );
    gh.factory<_i915.HomeBloc>(
      () => _i915.HomeBloc(gh<_i84.GetVendorStatsUseCase>()),
    );
    gh.singleton<_i365.AuthBloc>(
      () => _i365.AuthBloc(
        loginUseCase: gh<_i634.LoginUseCase>(),
        logoutUseCase: gh<_i357.LogoutUseCase>(),
        getCurrentUserUseCase: gh<_i277.GetCurrentUserUseCase>(),
      ),
    );
    gh.lazySingleton<_i340.FetchOrdersUseCase>(
      () => _i340.FetchOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i451.FetchDeliveredOrdersUseCase>(
      () => _i451.FetchDeliveredOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.factory<_i853.DeliveredOrderBloc>(
      () => _i853.DeliveredOrderBloc(
        fetchDeliveredOrdersUseCase: gh<_i451.FetchDeliveredOrdersUseCase>(),
      ),
    );
    gh.factory<_i238.OrderBloc>(
      () => _i238.OrderBloc(fetchOrdersUseCase: gh<_i340.FetchOrdersUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i769.RegisterModule {}
