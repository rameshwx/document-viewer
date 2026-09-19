// Static portfolio application metadata and local persistence keys.

class AppConstants {
  // App meta
  static const String appName =
  String.fromEnvironment('APP_NAME', defaultValue: 'AeroSlate');
  static const String appVersion =
  String.fromEnvironment('APP_VERSION', defaultValue: '0.0.0-dev');
  static const String drawingsBoxName = 'drawings';
}
