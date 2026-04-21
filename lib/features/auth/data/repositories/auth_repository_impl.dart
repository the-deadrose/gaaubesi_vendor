import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import 'package:gaaubesi_vendor/core/data/failure_mapper.dart';
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
      final user = await remoteDataSource.login(username, password);
      await localDataSource.saveUser(user);
      return Right(user);
    } catch (e) {
      return Left(toFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(toFailure(e));
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
      return Left(toFailure(e));
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
    } catch (e) {
      return Left(toFailure(e));
    }
  }
}
