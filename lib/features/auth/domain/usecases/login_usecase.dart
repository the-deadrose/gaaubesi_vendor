import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/auth/domain/entities/user_entity.dart';
import 'package:gaaubesi_vendor/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    debugPrint('🔑 [LoginUseCase] Executing login for: ${params.username}');
    final result = await repository.login(params.username, params.password);
    
    result.fold(
      (failure) => debugPrint('❌ [LoginUseCase] Login failed: ${failure.message}'),
      (user) => debugPrint('✅ [LoginUseCase] Login success for user: ${user.userId}'),
    );
    
    return result;
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}
