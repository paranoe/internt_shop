import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';

class RouteGuards {
  static String homeByRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return AppRoutes.adminDashboard;
      case 'seller':
        return AppRoutes.sellerDashboard;
      case 'buyer':
      default:
        return AppRoutes.buyerHome;
    }
  }

  static String? redirectByAuth({
    required AuthStatus status,
    required String location,
    required String? role,
  }) {
    final isAuthPage =
        location == AppRoutes.login ||
        location == AppRoutes.register ||
        location == AppRoutes.verifyEmail ||
        location == AppRoutes.forgotPassword ||
        location == AppRoutes.resetPassword;

    final isSplash = location == AppRoutes.splash;

    if (status == AuthStatus.initial || status == AuthStatus.loading) {
      return isSplash ? null : AppRoutes.splash;
    }

    if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
      if (isAuthPage) return null;
      return AppRoutes.login;
    }

    if (status == AuthStatus.authenticated) {
      if (isSplash || isAuthPage) {
        return homeByRole(role);
      }
      return null;
    }

    return AppRoutes.login;
  }
}
