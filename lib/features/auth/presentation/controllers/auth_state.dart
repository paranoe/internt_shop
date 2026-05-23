import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  verificationRequired,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.pendingEmail,
  });

  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? pendingEmail;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? pendingEmail,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, pendingEmail];
}
