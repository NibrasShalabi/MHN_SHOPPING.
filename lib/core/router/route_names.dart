
/// Centralized route paths — reference these everywhere instead of typing
/// raw path strings, so a path change never requires hunting across files.
abstract class RouteNames {
  RouteNames._();

  // Onboarding / Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main shell (bottom nav)
  static const String home = '/home';
  static const String cart = '/cart';
  static const String orderTracking = '/order-tracking';
  static const String about = '/about';
  static const String support = '/support';
  static const String rateApp = '/rate-app';

  // Catalog
  static const String category = '/category/:categoryId';
  static const String productDetails = '/product/:productId';

  // Orders
  //
  // No checkout route: the cart sends the order straight to the admin's
  // WhatsApp, so there is no intermediate screen to route to.
  static const String orderDetails = '/order/:orderId';

  // Loyalty
  static const String loyaltyStore = '/loyalty-store';

  // Fitness (female-only — guarded)
  //
  // The four supervised programs share one route with the program id as a
  // parameter: they render from the same screen, so separate paths would
  // just be four names for the same destination.
  static const String fitnessHome = '/fitness';
  static const String healthProgram = '/fitness/program/:programId';
  static const String supplements = '/fitness/supplements';

  // Suggest product
  static const String suggestProduct = '/suggest-product';

  // Notifications
  static const String notifications = '/notifications';

  static String categoryPath(String categoryId) => '/category/$categoryId';
  static String productPath(String productId) => '/product/$productId';
  static String orderPath(String orderId) => '/order/$orderId';
  static String sharedCartPath(String cartId) => '/shared-cart/$cartId';
  static String healthProgramPath(String programId) => '/fitness/program/$programId';
  static const String sharedCart = '/shared-cart/:cartId';
}