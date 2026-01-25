import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:gaaubesi_vendor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:gaaubesi_vendor/features/auth/domain/entities/user_entity.dart';
import 'package:gaaubesi_vendor/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String username,
    String password,
  ) async {
    try {
      debugPrint('📲 [AuthRepository] Login with username: $username');
      final user = await remoteDataSource.login(username, password);
      debugPrint('✅ [AuthRepository] User fetched from remote');

      // Save user data locally for persistence
      await localDataSource.saveUser(user);
      debugPrint('✅ [AuthRepository] User saved to local storage');

      return Right(user);
    } on ServerException catch (e) {
      debugPrint('❌ [AuthRepository] ServerException: ${e.message}');
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      debugPrint('❌ [AuthRepository] NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      debugPrint('❌ [AuthRepository] Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear locally stored user data
      await localDataSource.clearUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await remoteDataSource.changePassword(
        confirmPassword: confirmPassword,
        currentPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
