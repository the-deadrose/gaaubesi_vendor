// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

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
import 'package:gaaubesi_vendor/features/branch/data/datasource/branch_list_datasource.dart'
    as _i433;
import 'package:gaaubesi_vendor/features/branch/data/repository/branch_list_repo_imp.dart'
    as _i218;
import 'package:gaaubesi_vendor/features/branch/domain/repository/branch_list_repository.dart'
    as _i684;
import 'package:gaaubesi_vendor/features/branch/domain/usecase/get_branch_list_usecase.dart'
    as _i681;
import 'package:gaaubesi_vendor/features/branch/domain/usecase/get_pickup_point_usecase.dart'
    as _i598;
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch_list_bloc.dart'
    as _i764;
import 'package:gaaubesi_vendor/features/calculate_charge/data/datasource/calculate_delivery_charge_datasource.dart'
    as _i15;
import 'package:gaaubesi_vendor/features/calculate_charge/data/repo/calculate_delivery_charge_repo_imp.dart'
    as _i839;
import 'package:gaaubesi_vendor/features/calculate_charge/domain/repo/calculate_delivery_charge_repo.dart'
    as _i629;
import 'package:gaaubesi_vendor/features/calculate_charge/domain/usecase/calculate_delivery_charge_usecase.dart'
    as _i104;
import 'package:gaaubesi_vendor/features/calculate_charge/presentation/bloc/calculate_delivery_charge_bloc.dart'
    as _i44;
import 'package:gaaubesi_vendor/features/cod_transfer/data/datasource/cod_transfer_datasource.dart'
    as _i1017;
import 'package:gaaubesi_vendor/features/cod_transfer/data/repo/cod_transfer_repo_imp.dart'
    as _i841;
import 'package:gaaubesi_vendor/features/cod_transfer/domain/repo/cod_transfer_repo.dart'
    as _i646;
import 'package:gaaubesi_vendor/features/cod_transfer/domain/usecase/cod_transfer_list_usecase.dart'
    as _i414;
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_bloc.dart'
    as _i459;
import 'package:gaaubesi_vendor/features/comments/data/datasource/comments_datasource.dart'
    as _i170;
import 'package:gaaubesi_vendor/features/comments/data/repository/comments_repo_imp.dart'
    as _i944;
import 'package:gaaubesi_vendor/features/comments/domain/repository/comments_repository.dart'
    as _i92;
import 'package:gaaubesi_vendor/features/comments/domain/usecase/all_comments_usecase.dart'
    as _i932;
import 'package:gaaubesi_vendor/features/comments/domain/usecase/comment_reply_usecase.dart'
    as _i383;
import 'package:gaaubesi_vendor/features/comments/domain/usecase/create_comment_orderdetail_usecase.dart'
    as _i350;
import 'package:gaaubesi_vendor/features/comments/domain/usecase/filtered_comments_usecase.dart'
    as _i625;
import 'package:gaaubesi_vendor/features/comments/domain/usecase/reply_comment_order_detail_usecase.dart'
    as _i942;
import 'package:gaaubesi_vendor/features/comments/domain/usecase/todays_comments_usecase.dart'
    as _i427;
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart'
    as _i11;
import 'package:gaaubesi_vendor/features/customer/data/datasource/customer_datasource.dart'
    as _i88;
import 'package:gaaubesi_vendor/features/customer/data/repo/customer_repo_imp.dart'
    as _i362;
import 'package:gaaubesi_vendor/features/customer/domain/repository/customer_repo.dart'
    as _i894;
import 'package:gaaubesi_vendor/features/customer/domain/usecase/customer_list_usecase.dart'
    as _i25;
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/customer_bloc.dart'
    as _i512;
import 'package:gaaubesi_vendor/features/daily_transections/data/datasource/daily_transection_datasource.dart'
    as _i339;
import 'package:gaaubesi_vendor/features/daily_transections/data/repo/daily_transection_repo_imp.dart'
    as _i11;
import 'package:gaaubesi_vendor/features/daily_transections/domain/repo/daily_transection_repo.dart'
    as _i523;
import 'package:gaaubesi_vendor/features/daily_transections/domain/usecase/fetch_daily_transaction_usecase.dart'
    as _i7;
import 'package:gaaubesi_vendor/features/daily_transections/presentation/bloc/daily_transaction_bloc.dart'
    as _i117;
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
import 'package:gaaubesi_vendor/features/notice/data/datasource/notice_datasource.dart'
    as _i906;
import 'package:gaaubesi_vendor/features/notice/data/repo/notice_list_repo_imp.dart'
    as _i1054;
import 'package:gaaubesi_vendor/features/notice/domain/repo/notice_repository.dart'
    as _i795;
import 'package:gaaubesi_vendor/features/notice/domain/usecase/notice_list_usecase.dart'
    as _i83;
import 'package:gaaubesi_vendor/features/notice/presentation/bloc/notice_bloc.dart'
    as _i587;
import 'package:gaaubesi_vendor/features/orderdetail/domain/usecase/fetch_order_detail_usecase.dart'
    as _i170;
import 'package:gaaubesi_vendor/features/orders/data/datasources/order_remote_data_source.dart'
    as _i700;
import 'package:gaaubesi_vendor/features/orders/data/repositories/order_repository_impl.dart'
    as _i800;
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart'
    as _i532;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/create_order_usecase.dart'
    as _i353;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/edit_order_usecase.dart'
    as _i1054;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_delivered_orders_usecase.dart'
    as _i451;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_orders_usecase.dart'
    as _i340;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_possible_redirect_orders_usecase.dart'
    as _i83;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_redirected_usecsae.dart'
    as _i522;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_returned_orders_usecase.dart'
    as _i466;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_rtv_orders_usecase.dart'
    as _i287;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_stale_orders_usecase.dart'
    as _i255;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_todays_redirect_usecase.dart'
    as _i358;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/search_orders_usecase.dart'
    as _i1053;
import 'package:gaaubesi_vendor/features/orders/domain/usecases/warehouse_order_list_usecase.dart'
    as _i459;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order/delivered_order_bloc.dart'
    as _i37;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order/order_bloc.dart'
    as _i626;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_bloc.dart'
    as _i124;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_bloc.dart'
    as _i894;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_bloc.dart'
    as _i114;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order/returned_order_bloc.dart'
    as _i337;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order/rtv_order_bloc.dart'
    as _i691;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_bloc.dart'
    as _i850;
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/warehouse/warehouse_order_bloc.dart'
    as _i682;
import 'package:gaaubesi_vendor/features/payment_request/data/datasource/payment_request_datasource.dart'
    as _i515;
import 'package:gaaubesi_vendor/features/payment_request/data/repo/payment_request_repo_imp.dart'
    as _i771;
import 'package:gaaubesi_vendor/features/payment_request/domain/repo/payment_request_repo.dart'
    as _i492;
import 'package:gaaubesi_vendor/features/payment_request/domain/usecase/create_payment_request_usecase.dart'
    as _i151;
import 'package:gaaubesi_vendor/features/payment_request/domain/usecase/fetch_frequently_used_payment_usecase.dart'
    as _i935;
import 'package:gaaubesi_vendor/features/payment_request/domain/usecase/fetch_payment_request_usecase.dart'
    as _i324;
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/frequently_used_methods/frequently_used_payment_method_bloc.dart'
    as _i218;
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_bloc.dart'
    as _i724;
import 'package:gaaubesi_vendor/features/ticket/data/datasource/tickect_datasorce.dart'
    as _i576;
import 'package:gaaubesi_vendor/features/ticket/data/repository/ticket_imp_repository.dart'
    as _i716;
import 'package:gaaubesi_vendor/features/ticket/domain/repository/ticket_repository.dart'
    as _i567;
import 'package:gaaubesi_vendor/features/ticket/domain/usecase/create_ticket_usecase.dart'
    as _i1050;
import 'package:gaaubesi_vendor/features/ticket/domain/usecase/tickets_list_usecase.dart'
    as _i457;
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_bloc.dart'
    as _i488;
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
    gh.lazySingleton<_i14.SecureStorageService>(
      () => _i14.SecureStorageServiceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i619.DioClient>(
      () => _i619.DioClient(gh<_i361.Dio>(), gh<_i14.SecureStorageService>()),
    );
    gh.lazySingleton<_i433.BranchListRemoteDatasource>(
      () => _i433.BranchListDatasourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i18.AuthLocalDataSource>(
      () => _i18.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i515.PaymentRequestRemoteDatasource>(
      () => _i515.PaymentRequestDatasourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i576.RemoteTicketDataSource>(
      () => _i576.TickectDatasorceImp(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i1017.CodTransferRemoteDataource>(
      () => _i1017.CodTransferDatasourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i700.OrderRemoteDataSource>(
      () => _i700.OrderRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i906.NoticeRemoteDatasource>(
      () => _i906.NoticeRemoteDatasourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i311.AuthRemoteDataSource>(
      () => _i311.AuthRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i15.CalculateDeliveryChargeRemoteDatasource>(
      () => _i15.CalculateDeliveryChargeDatasourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i630.HomeRemoteDataSource>(
      () => _i630.HomeRemoteDataSourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i339.DailyTransectionRemoteDatasource>(
      () => _i339.DailyTransectionDatasourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i88.CustomerRemoteDatasource>(
      () => _i88.CustomerRemoteDatasourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i170.CommentsRemoteDatasource>(
      () => _i170.CommentsDatasourceImpl(gh<_i619.DioClient>()),
    );
    gh.lazySingleton<_i532.OrderRepository>(
      () => _i800.OrderRepositoryImpl(
        remoteDataSource: gh<_i700.OrderRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i684.BranchListRepository>(
      () => _i218.BranchListRepoImp(
        remoteDatasource: gh<_i433.BranchListRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i681.GetBranchListUsecase>(
      () => _i681.GetBranchListUsecase(gh<_i684.BranchListRepository>()),
    );
    gh.lazySingleton<_i598.GetPickupPointUsecase>(
      () => _i598.GetPickupPointUsecase(gh<_i684.BranchListRepository>()),
    );
    gh.lazySingleton<_i629.CalculateDeliveryChargeRepo>(
      () => _i839.CalculateDeliveryChargeRepoImp(
        remoteDatasource: gh<_i15.CalculateDeliveryChargeRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i104.CalculateDeliveryChargeUsecase>(
      () => _i104.CalculateDeliveryChargeUsecase(
        gh<_i629.CalculateDeliveryChargeRepo>(),
      ),
    );
    gh.lazySingleton<_i492.PaymentRequestRepo>(
      () => _i771.PaymentRequestRepoImp(
        remoteDatasource: gh<_i515.PaymentRequestRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i170.FetchOrderDetailUseCase>(
      () => _i170.FetchOrderDetailUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i353.CreateOrderUseCase>(
      () => _i353.CreateOrderUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i1054.EditOrderUseCase>(
      () => _i1054.EditOrderUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i451.FetchDeliveredOrdersUseCase>(
      () => _i451.FetchDeliveredOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i340.FetchOrdersUseCase>(
      () => _i340.FetchOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i83.FetchPossibleRedirectOrdersUseCase>(
      () =>
          _i83.FetchPossibleRedirectOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i522.FetchRedirectedUsecsae>(
      () => _i522.FetchRedirectedUsecsae(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i466.FetchReturnedOrdersUseCase>(
      () => _i466.FetchReturnedOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i287.FetchRtvOrdersUseCase>(
      () => _i287.FetchRtvOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i255.FetchStaleOrdersUseCase>(
      () => _i255.FetchStaleOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i358.FetchTodaysRedirectUsecase>(
      () => _i358.FetchTodaysRedirectUsecase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i1053.SearchOrdersUseCase>(
      () => _i1053.SearchOrdersUseCase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i459.WarehouseOrderListUsecase>(
      () => _i459.WarehouseOrderListUsecase(gh<_i532.OrderRepository>()),
    );
    gh.lazySingleton<_i92.CommentsRepository>(
      () => _i944.CommentsRepoImp(
        remoteDatasource: gh<_i170.CommentsRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i103.HomeRepository>(
      () => _i990.HomeRepositoryImpl(gh<_i630.HomeRemoteDataSource>()),
    );
    gh.lazySingleton<_i523.DailyTransectionRepo>(
      () => _i11.DailyTransectionRepoImp(
        remoteDatasource: gh<_i339.DailyTransectionRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i40.AuthRepository>(
      () => _i635.AuthRepositoryImpl(
        remoteDataSource: gh<_i311.AuthRemoteDataSource>(),
        localDataSource: gh<_i18.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i795.NoticeRepository>(
      () => _i1054.NoticeListRepoImp(
        remoteDatasource: gh<_i906.NoticeRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i84.GetVendorStatsUseCase>(
      () => _i84.GetVendorStatsUseCase(gh<_i103.HomeRepository>()),
    );
    gh.lazySingleton<_i83.NoticeListUsecase>(
      () => _i83.NoticeListUsecase(gh<_i795.NoticeRepository>()),
    );
    gh.factory<_i682.WarehouseOrderBloc>(
      () => _i682.WarehouseOrderBloc(
        warehouseOrderListUsecase: gh<_i459.WarehouseOrderListUsecase>(),
      ),
    );
    gh.lazySingleton<_i567.TicketRepository>(
      () => _i716.TicketImpRepository(
        remoteTicketDataSource: gh<_i576.RemoteTicketDataSource>(),
      ),
    );
    gh.factory<_i114.RedirectedOrdersBloc>(
      () => _i114.RedirectedOrdersBloc(
        gh<_i522.FetchRedirectedUsecsae>(),
        gh<_i358.FetchTodaysRedirectUsecase>(),
      ),
    );
    gh.lazySingleton<_i151.CreatePaymentRequestUsecase>(
      () => _i151.CreatePaymentRequestUsecase(gh<_i492.PaymentRequestRepo>()),
    );
    gh.lazySingleton<_i935.FetchFrequentlyUsedPaymentUsecase>(
      () => _i935.FetchFrequentlyUsedPaymentUsecase(
        gh<_i492.PaymentRequestRepo>(),
      ),
    );
    gh.lazySingleton<_i324.FetchPaymentRequestUsecase>(
      () => _i324.FetchPaymentRequestUsecase(gh<_i492.PaymentRequestRepo>()),
    );
    gh.lazySingleton<_i646.CodTransferRepo>(
      () => _i841.CodTransferRepoImp(
        remoteDataSource: gh<_i1017.CodTransferRemoteDataource>(),
      ),
    );
    gh.factory<_i850.StaleOrderBloc>(
      () => _i850.StaleOrderBloc(
        fetchStaleOrdersUseCase: gh<_i255.FetchStaleOrdersUseCase>(),
      ),
    );
    gh.lazySingleton<_i277.GetCurrentUserUseCase>(
      () => _i277.GetCurrentUserUseCase(gh<_i40.AuthRepository>()),
    );
    gh.lazySingleton<_i634.LoginUseCase>(
      () => _i634.LoginUseCase(gh<_i40.AuthRepository>()),
    );
    gh.lazySingleton<_i357.LogoutUseCase>(
      () => _i357.LogoutUseCase(gh<_i40.AuthRepository>()),
    );
    gh.factory<_i587.NoticeBloc>(
      () => _i587.NoticeBloc(gh<_i83.NoticeListUsecase>()),
    );
    gh.singleton<_i365.AuthBloc>(
      () => _i365.AuthBloc(
        loginUseCase: gh<_i634.LoginUseCase>(),
        logoutUseCase: gh<_i357.LogoutUseCase>(),
        getCurrentUserUseCase: gh<_i277.GetCurrentUserUseCase>(),
      ),
    );
    gh.factory<_i691.RtvOrderBloc>(
      () => _i691.RtvOrderBloc(
        fetchRtvOrdersUseCase: gh<_i287.FetchRtvOrdersUseCase>(),
      ),
    );
    gh.factory<_i37.DeliveredOrderBloc>(
      () => _i37.DeliveredOrderBloc(
        fetchDeliveredOrdersUseCase: gh<_i451.FetchDeliveredOrdersUseCase>(),
      ),
    );
    gh.lazySingleton<_i894.CustomerRepo>(
      () => _i362.CustomerRepoImp(
        remoteDataSource: gh<_i88.CustomerRemoteDatasource>(),
      ),
    );
    gh.factory<_i124.OrderDetailBloc>(
      () => _i124.OrderDetailBloc(
        fetchOrderDetailUseCase: gh<_i170.FetchOrderDetailUseCase>(),
        editOrderUseCase: gh<_i1054.EditOrderUseCase>(),
      ),
    );
    gh.lazySingleton<_i7.FetchDailyTransactionUsecase>(
      () => _i7.FetchDailyTransactionUsecase(gh<_i523.DailyTransectionRepo>()),
    );
    gh.factory<_i724.PaymentRequestBloc>(
      () => _i724.PaymentRequestBloc(
        gh<_i151.CreatePaymentRequestUsecase>(),
        gh<_i324.FetchPaymentRequestUsecase>(),
      ),
    );
    gh.factory<_i894.PossibleRedirectOrderBloc>(
      () => _i894.PossibleRedirectOrderBloc(
        fetchPossibleRedirectOrdersUseCase:
            gh<_i83.FetchPossibleRedirectOrdersUseCase>(),
      ),
    );
    gh.factory<_i44.CalculateDeliveryChargeBloc>(
      () => _i44.CalculateDeliveryChargeBloc(
        gh<_i104.CalculateDeliveryChargeUsecase>(),
      ),
    );
    gh.factory<_i764.BranchListBloc>(
      () => _i764.BranchListBloc(
        getBranchListUsecase: gh<_i681.GetBranchListUsecase>(),
        getPickupPointUsecase: gh<_i598.GetPickupPointUsecase>(),
      ),
    );
    gh.factory<_i915.HomeBloc>(
      () => _i915.HomeBloc(gh<_i84.GetVendorStatsUseCase>()),
    );
    gh.lazySingleton<_i932.AllCommentsUsecase>(
      () => _i932.AllCommentsUsecase(gh<_i92.CommentsRepository>()),
    );
    gh.lazySingleton<_i383.CommentReplyUsecase>(
      () => _i383.CommentReplyUsecase(gh<_i92.CommentsRepository>()),
    );
    gh.lazySingleton<_i350.CreateCommentOrderdetailUsecase>(
      () =>
          _i350.CreateCommentOrderdetailUsecase(gh<_i92.CommentsRepository>()),
    );
    gh.lazySingleton<_i625.FilteredCommentsUsecase>(
      () => _i625.FilteredCommentsUsecase(gh<_i92.CommentsRepository>()),
    );
    gh.lazySingleton<_i942.ReplyCommentOrderDetailUsecase>(
      () => _i942.ReplyCommentOrderDetailUsecase(gh<_i92.CommentsRepository>()),
    );
    gh.lazySingleton<_i427.TodaysCommentsUsecase>(
      () => _i427.TodaysCommentsUsecase(gh<_i92.CommentsRepository>()),
    );
    gh.lazySingleton<_i1050.CreateTicketUseCase>(
      () =>
          _i1050.CreateTicketUseCase(repository: gh<_i567.TicketRepository>()),
    );
    gh.lazySingleton<_i457.TicketsListUseCase>(
      () => _i457.TicketsListUseCase(repository: gh<_i567.TicketRepository>()),
    );
    gh.factory<_i337.ReturnedOrderBloc>(
      () => _i337.ReturnedOrderBloc(
        fetchReturnedOrdersUseCase: gh<_i466.FetchReturnedOrdersUseCase>(),
      ),
    );
    gh.factory<_i626.OrderBloc>(
      () => _i626.OrderBloc(
        fetchOrdersUseCase: gh<_i340.FetchOrdersUseCase>(),
        createOrderUseCase: gh<_i353.CreateOrderUseCase>(),
      ),
    );
    gh.factory<_i117.DailyTransactionBloc>(
      () => _i117.DailyTransactionBloc(gh<_i7.FetchDailyTransactionUsecase>()),
    );
    gh.factory<_i11.CommentsBloc>(
      () => _i11.CommentsBloc(
        todaysCommentsUsecase: gh<_i427.TodaysCommentsUsecase>(),
        allCommentsUsecase: gh<_i932.AllCommentsUsecase>(),
        filteredCommentsUsecase: gh<_i625.FilteredCommentsUsecase>(),
        commentReplyUsecase: gh<_i383.CommentReplyUsecase>(),
        createCommentOrderdetailUsecase:
            gh<_i350.CreateCommentOrderdetailUsecase>(),
        replyCommentOrderDetailUsecase:
            gh<_i942.ReplyCommentOrderDetailUsecase>(),
      ),
    );
    gh.lazySingleton<_i414.CodTransferListUsecase>(
      () => _i414.CodTransferListUsecase(gh<_i646.CodTransferRepo>()),
    );
    gh.factory<_i218.FrequentlyUsedPaymentMethodBloc>(
      () => _i218.FrequentlyUsedPaymentMethodBloc(
        gh<_i935.FetchFrequentlyUsedPaymentUsecase>(),
      ),
    );
    gh.lazySingleton<_i25.CustomerListUseCase>(
      () => _i25.CustomerListUseCase(gh<_i894.CustomerRepo>()),
    );
    gh.factory<_i459.CodTransferBloc>(
      () => _i459.CodTransferBloc(
        codTransferListUsecase: gh<_i414.CodTransferListUsecase>(),
      ),
    );
    gh.factory<_i488.TicketBloc>(
      () => _i488.TicketBloc(
        ticketsListUseCase: gh<_i457.TicketsListUseCase>(),
        createTicketUseCase: gh<_i1050.CreateTicketUseCase>(),
      ),
    );
    gh.factory<_i512.CustomerBloc>(
      () => _i512.CustomerBloc(gh<_i25.CustomerListUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i769.RegisterModule {}
