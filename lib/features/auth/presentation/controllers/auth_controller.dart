import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/core/storage/secure_storage.dart';
import 'package:diplomeprojectmobile/core/utils/error_mapper.dart';
import '../../data/datasources/auth_api.dart';
import '../../data/repos/auth_repo_impl.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_session_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthController extends Cubit<AuthState> {
  AuthController({
    required SecureStorage secureStorage,
    required AuthApi authApi,
  }) : _secureStorage = secureStorage,
       _authApi = authApi,
       _loginUseCase = LoginUseCase(_buildRepo(authApi)),
       _registerUseCase = RegisterUseCase(_buildRepo(authApi)),
       _refreshSessionUseCase = RefreshSessionUseCase(_buildRepo(authApi)),
       _logoutUseCase = LogoutUseCase(_buildRepo(authApi)),
       _getMeUseCase = GetMeUseCase(_buildRepo(authApi)),
       super(const AuthState());

  final SecureStorage _secureStorage;
  final AuthApi _authApi;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final RefreshSessionUseCase _refreshSessionUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetMeUseCase _getMeUseCase;

  static AuthRepoImpl _buildRepo(AuthApi authApi) => AuthRepoImpl(authApi);

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
    print('AUTH REGISTER START');

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await _registerUseCase(
        email: email,
        password: password,
        role: role,
        shopName: shopName,
      );

      print('AUTH REGISTER SUCCESS');

      emit(
        state.copyWith(
          status: AuthStatus.initial,
          pendingEmail: email,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      print('AUTH REGISTER ERROR = $e');

      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
      return false;
    }
  }

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await _authApi.verifyEmail(email: email, code: code);

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          pendingEmail: email,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          pendingEmail: email,
          errorMessage: ErrorMapper.map(e),
        ),
      );
      return false;
    }
  }

  Future<bool> resendVerificationCode({required String email}) async {
    try {
      await _authApi.resendVerificationCode(email: email);
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          pendingEmail: email,
          errorMessage: ErrorMapper.map(e),
        ),
      );
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    print('AUTH FORGOT PASSWORD START');

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await _authApi.forgotPassword(email: email);

      print('AUTH FORGOT PASSWORD SUCCESS');

      emit(
        state.copyWith(
          status: AuthStatus.initial,
          pendingEmail: email,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      print('AUTH FORGOT PASSWORD ERROR = $e');

      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await _authApi.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearError: true),
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

  Future<void> init() async {
    print('AUTH INIT START');
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final access = await _secureStorage.getAccessToken();
    final refresh = await _secureStorage.getRefreshToken();

    print('ACCESS: $access');
    print('REFRESH: $refresh');

    final hasAccess = access != null && access.isNotEmpty;
    final hasRefresh = refresh != null && refresh.isNotEmpty;

    if (!hasAccess && !hasRefresh) {
      print('NO TOKENS -> unauthenticated');
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    try {
      if (!hasAccess) {
        print('TRY REFRESH');
        final newAccess = await _refreshSessionUseCase(refreshToken: refresh!);

        await _secureStorage.saveTokens(
          accessToken: newAccess,
          refreshToken: refresh,
        );
      }

      print('TRY GET ME');
      final me = await _getMeUseCase();

      print('GET ME OK: ${me.role}');
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: me,
          clearError: true,
        ),
      );
    } catch (e) {
      print('INIT ERROR 1: $e');

      if (hasRefresh) {
        try {
          print('TRY REFRESH AGAIN');
          final newAccess = await _refreshSessionUseCase(
            refreshToken: refresh!,
          );

          await _secureStorage.saveTokens(
            accessToken: newAccess,
            refreshToken: refresh,
          );

          final me = await _getMeUseCase();

          print('GET ME AFTER REFRESH OK: ${me.role}');
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: me,
              clearError: true,
            ),
          );
          return;
        } catch (e) {
          print('INIT ERROR 2: $e');
        }
      }

      await _secureStorage.clearTokens();
      print('CLEAR TOKENS -> unauthenticated');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Сессия истекла. Войдите снова.',
        ),
      );
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
