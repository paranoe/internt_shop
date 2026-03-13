import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';

class RouteGuards {
  RouteGuards._();

  static String _homeByRole(String? role) {
    switch ((role ?? '').toLowerCase()) {
      case 'seller':
        return AppRoutes.sellerDashboard;
      case 'admin':
        return AppRoutes.adminDashboard;
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
        location == AppRoutes.login || location == AppRoutes.register;
    final isSplash = location == AppRoutes.splash;

    if (status == AuthStatus.loading || status == AuthStatus.initial) {
      return isSplash ? null : AppRoutes.splash;
    }

    if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
      return isAuthPage ? null : AppRoutes.login;
    }

    if (status == AuthStatus.authenticated) {
      final target = _homeByRole(role);
      if (isSplash || isAuthPage) return target;
    }

    return null;
  }

  static String homeByRole(String? role) => _homeByRole(role);
}
