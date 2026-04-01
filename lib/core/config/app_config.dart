enum AppFlavor { dev, staging, prod }

class AppConfig {
  final AppFlavor flavor;
  final String baseUrl;
  final String envName;
  final bool enableDebugLogs;
  final bool showEnvBanner;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;

  const AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.envName,
    required this.enableDebugLogs,
    required this.showEnvBanner,
    this.connectTimeoutMs = 15000,
    this.receiveTimeoutMs = 15000,
  });

  factory AppConfig.fromEnvironment() {
    const flavorStr = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    switch (flavorStr) {
      case 'prod':
        return const AppConfig(
          flavor: AppFlavor.prod,
          baseUrl: 'https://api.company.com/api/v1',
          envName: 'Production',
          enableDebugLogs: false,
          showEnvBanner: false,
          connectTimeoutMs: 15000,
          receiveTimeoutMs: 15000,
        );
      case 'staging':
        return const AppConfig(
          flavor: AppFlavor.staging,
          baseUrl: 'https://staging-api.company.com/api/v1',
          envName: 'Staging',
          enableDebugLogs: true,
          showEnvBanner: true,
          connectTimeoutMs: 20000,
          receiveTimeoutMs: 20000,
        );
      case 'dev':
      default:
        return const AppConfig(
          flavor: AppFlavor.dev,
          // baseUrl: 'http://192.168.1.41:8000/api/v1',
          baseUrl: 'https://account.alzajeltravel.com/api/v1',
          envName: 'Development',
          enableDebugLogs: true,
          showEnvBanner: true,
          connectTimeoutMs: 30000,
          receiveTimeoutMs: 30000,
        );
    }
  }

  bool get isProduction => flavor == AppFlavor.prod;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isDev => flavor == AppFlavor.dev;

  @override
  String toString() => 'AppConfig($envName, $baseUrl)';
}
