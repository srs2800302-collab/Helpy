class AppConfig {
  final String apiBaseUrl;

  const AppConfig({
    required this.apiBaseUrl,
  });

  factory AppConfig.dev() {
    return const AppConfig(
      apiBaseUrl: 'http://localhost:3000/api/v1',
    );
  }
}
