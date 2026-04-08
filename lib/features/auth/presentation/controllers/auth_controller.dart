import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/core/storage/secure_storage.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/repos/auth_repo_impl.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_session_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'package:diplomeprojectmobile/core/utils/error_mapper.dart';
import 'auth_state.dart';

class AuthController extends Cubit<AuthState> {
  AuthController({
    required SecureStorage secureStorage,
    required AuthApi authApi,
  }) : _secureStorage = secureStorage,
       _loginUseCase = LoginUseCase(_buildRepo(authApi)),
       _registerUseCase = RegisterUseCase(_buildRepo(authApi)),
       _refreshSessionUseCase = RefreshSessionUseCase(_buildRepo(authApi)),
       _logoutUseCase = LogoutUseCase(_buildRepo(authApi)),
       _getMeUseCase = GetMeUseCase(_buildRepo(authApi)),
       super(const AuthState());

  final SecureStorage _secureStorage;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final RefreshSessionUseCase _refreshSessionUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetMeUseCase _getMeUseCase;

  static AuthRepoImpl _buildRepo(AuthApi authApi) => AuthRepoImpl(authApi);

  Future<void> init() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final access = await _secureStorage.getAccessToken();
    final refresh = await _secureStorage.getRefreshToken();

    final hasAccess = access != null && access.isNotEmpty;
    final hasRefresh = refresh != null && refresh.isNotEmpty;

    if (!hasAccess && !hasRefresh) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    try {
      if (!hasAccess) {
        final newAccess = await _refreshSessionUseCase(refreshToken: refresh!);

        await _secureStorage.saveTokens(
          accessToken: newAccess,
          refreshToken: refresh,
        );
      }

      final me = await _getMeUseCase();

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: me,
          clearError: true,
        ),
      );
    } catch (_) {
      if (hasRefresh) {
        try {
          final newAccess = await _refreshSessionUseCase(
            refreshToken: refresh!,
          );

          await _secureStorage.saveTokens(
            accessToken: newAccess,
            refreshToken: refresh,
          );

          final me = await _getMeUseCase();

          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: me,
              clearError: true,
            ),
          );
          return;
        } catch (_) {}
      }

      await _secureStorage.clearTokens();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Сессия истекла. Войдите снова.',
        ),
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final tokens = await _loginUseCase(email: email, password: password);

      await _secureStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      final me = await _getMeUseCase();

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: me,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String role,
    String? shopName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final tokens = await _registerUseCase(
        email: email,
        password: password,
        role: role,
        shopName: shopName,
      );

      await _secureStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      final me = await _getMeUseCase();

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: me,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final refresh = await _secureStorage.getRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
        await _logoutUseCase(refreshToken: refresh);
      }
    } catch (_) {}

    await _secureStorage.clearTokens();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
