import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';

class RouteGuards {
  static bool _isAuthPage(String location) {
    return location == AppRoutes.login ||
        location == AppRoutes.register ||
        location == AppRoutes.verifyEmail ||
        location == AppRoutes.forgotPassword ||
        location == AppRoutes.resetPassword;
  }

  static bool _isAdminOrSellerRoute(String location) {
    return location.startsWith('/admin') || location.startsWith('/seller');
  }

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
    final isSplash = location == AppRoutes.splash;

    if (status == AuthStatus.initial || status == AuthStatus.loading) {
      return isSplash ? null : AppRoutes.splash;
    }

    if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
      // Когда гость открывает приложение — ведём не на login, а в каталог
      if (isSplash) {
        return AppRoutes.buyerHome;
      }

      // Login/register должны открываться, когда пользователь сам нажал "Войти"
      if (_isAuthPage(location)) {
        return null;
      }

      // Admin/seller без входа нельзя
      if (_isAdminOrSellerRoute(location)) {
        return AppRoutes.login;
      }

      // Buyer-экраны разрешаем гостю.
      // Недоступные экраны покажут AuthRequired внутри UI.
      return null;
    }

    if (status == AuthStatus.authenticated) {
      if (isSplash || _isAuthPage(location)) {
        return homeByRole(role);
      }

      return null;
    }

    return AppRoutes.buyerHome;
  }
}
