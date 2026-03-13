class ApiEndpoints {
  ApiEndpoints._();

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/me';

  static const categories = '/categories';
  static const products = '/products';
  static const cart = '/cart';
  static const checkoutPreview = '/checkout/preview';
  static const checkoutCreate = '/checkout/create';
  static const orders = '/orders';
  static const reviews = '/reviews';

  static const cities = '/cities';
  static const pickupPoints = '/pickup-points';
  static const paymentMethods = '/payment-methods';
  static const listTypes = '/list-types';
  static const myCards = '/me/cards';

  static const sellerProfile = '/seller/profile';
  static const sellerProducts = '/seller/products';
  static const sellerOrders = '/seller/orders';

  static const adminUsers = '/admin/users';
  static const adminOrders = '/admin/orders';
  static const adminPayments = '/admin/payments';
}
