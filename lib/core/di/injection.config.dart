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
import 'package:gaaubesi_vendor/app/auth/data/datasources/auth_local_data_source.dart'
    as _i697;
import 'package:gaaubesi_vendor/app/auth/data/datasources/auth_remote_data_source.dart'
    as _i623;
import 'package:gaaubesi_vendor/app/auth/data/repositories/auth_repository_impl.dart'
    as _i928;
import 'package:gaaubesi_vendor/app/auth/domain/repositories/auth_repository.dart'
    as _i113;
import 'package:gaaubesi_vendor/app/auth/domain/usecases/get_current_user_usecase.dart'
    as _i158;
import 'package:gaaubesi_vendor/app/auth/domain/usecases/login_usecase.dart'
    as _i740;
import 'package:gaaubesi_vendor/app/auth/domain/usecases/logout_usecase.dart'
    as _i1020;
import 'package:gaaubesi_vendor/app/auth/presentation/bloc/auth_bloc.dart'
    as _i1047;
import 'package:gaaubesi_vendor/app/comments/data/datasource/comments_datasource.dart'
    as _i103;
import 'package:gaaubesi_vendor/app/comments/data/repository/comments_repo_imp.dart'
    as _i51;
import 'package:gaaubesi_vendor/app/comments/domain/repository/comments_repository.dart'
    as _i581;
import 'package:gaaubesi_vendor/app/comments/domain/usecase/todays_comments_usecase.dart'
    as _i253;
import 'package:gaaubesi_vendor/app/comments/presentation/bloc/todays_comments_bloc.dart'
    as _i927;
import 'package:gaaubesi_vendor/app/home/data/datasources/home_remote_data_source.dart'
    as _i610;
import 'package:gaaubesi_vendor/app/home/data/repositories/home_repository_impl.dart'
    as _i335;
import 'package:gaaubesi_vendor/app/home/domain/repositories/home_repository.dart'
    as _i701;
import 'package:gaaubesi_vendor/app/home/domain/usecases/get_vendor_stats_usecase.dart'
    as _i642;
import 'package:gaaubesi_vendor/app/home/presentation/bloc/home_bloc.dart'
    as _i463;
import 'package:gaaubesi_vendor/app/orders/data/datasources/order_remote_data_source.dart'
    as _i814;
import 'package:gaaubesi_vendor/app/orders/data/repositories/order_repository_impl.dart'
    as _i32;
import 'package:gaaubesi_vendor/app/orders/domain/repositories/order_repository.dart'
    as _i899;
import 'package:gaaubesi_vendor/app/orders/domain/usecases/fetch_delivered_orders_usecase.dart'
    as _i640;
import 'package:gaaubesi_vendor/app/orders/domain/usecases/fetch_orders_usecase.dart'
    as _i804;
import 'package:gaaubesi_vendor/app/orders/presentation/bloc/delivered_order_bloc.dart'
    as _i0;
import 'package:gaaubesi_vendor/app/orders/presentation/bloc/order_bloc.dart'
    as _i205;
import 'package:gaaubesi_vendor/core/di/register_module.dart' as _i769;
import 'package:gaaubesi_vendor/core/network/dio_client.dart' as _i619;
import 'package:gaaubesi_vendor/core/router/app_router.dart' as _i694;
import 'package:gaaubesi_vendor/core/services/secure_storage_service.dart'
    as _i14;
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
    gh.lazySingleton<_i697.AuthLocalDataSource>(
      () => _i697.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i14.SecureStorageService>(
      () => _i14.SecureStorageServiceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i619.DioClient>(
      () => _i619.DioClient(gh<_i361.Dio>(), gh<_i14.SecureStorageService>()),
    );
    gh.lazySingleton<_i814.OrderRemoteDataSource>(
      () => _i814.OrderRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i899.OrderRepository>(
      () => _i32.OrderRepositoryImpl(
        remoteDataSource: gh<_i814.OrderRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i804.FetchOrdersUseCase>(
      () => _i804.FetchOrdersUseCase(gh<_i899.OrderRepository>()),
    );
    gh.lazySingleton<_i640.FetchDeliveredOrdersUseCase>(
      () => _i640.FetchDeliveredOrdersUseCase(gh<_i899.OrderRepository>()),
    );
    gh.lazySingleton<_i103.CommentsDatasource>(
      () => _i103.CommentsDataSourceImps(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i623.AuthRemoteDataSource>(
      () => _i623.AuthRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i610.HomeRemoteDataSource>(
      () => _i610.HomeRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.factory<_i205.OrderBloc>(
      () => _i205.OrderBloc(fetchOrdersUseCase: gh<_i804.FetchOrdersUseCase>()),
    );
    gh.lazySingleton<_i113.AuthRepository>(
      () => _i928.AuthRepositoryImpl(
        remoteDataSource: gh<_i623.AuthRemoteDataSource>(),
        localDataSource: gh<_i697.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i0.DeliveredOrderBloc>(
      () => _i0.DeliveredOrderBloc(
        fetchDeliveredOrdersUseCase: gh<_i640.FetchDeliveredOrdersUseCase>(),
      ),
    );
    gh.lazySingleton<_i701.HomeRepository>(
      () => _i335.HomeRepositoryImpl(gh<_i610.HomeRemoteDataSource>()),
    );
    gh.lazySingleton<_i642.GetVendorStatsUseCase>(
      () => _i642.GetVendorStatsUseCase(gh<_i701.HomeRepository>()),
    );
    gh.lazySingleton<_i581.CommentsRepository>(
      () => _i51.CommentsRepoImp(gh<_i103.CommentsDatasource>()),
    );
    gh.lazySingleton<_i253.TodaysCommentsUseCase>(
      () => _i253.TodaysCommentsUseCase(gh<_i581.CommentsRepository>()),
    );
    gh.factory<_i463.HomeBloc>(
      () => _i463.HomeBloc(
        gh<_i642.GetVendorStatsUseCase>(),
        gh<_i14.SecureStorageService>(),
      ),
    );
    gh.lazySingleton<_i158.GetCurrentUserUseCase>(
      () => _i158.GetCurrentUserUseCase(gh<_i113.AuthRepository>()),
    );
    gh.lazySingleton<_i1020.LogoutUseCase>(
      () => _i1020.LogoutUseCase(gh<_i113.AuthRepository>()),
    );
    gh.lazySingleton<_i740.LoginUseCase>(
      () => _i740.LoginUseCase(gh<_i113.AuthRepository>()),
    );
    gh.factory<_i927.TodaysCommentsBloc>(
      () => _i927.TodaysCommentsBloc(gh<_i253.TodaysCommentsUseCase>()),
    );
    gh.singleton<_i1047.AuthBloc>(
      () => _i1047.AuthBloc(
        loginUseCase: gh<_i740.LoginUseCase>(),
        logoutUseCase: gh<_i1020.LogoutUseCase>(),
        getCurrentUserUseCase: gh<_i158.GetCurrentUserUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i769.RegisterModule {}
