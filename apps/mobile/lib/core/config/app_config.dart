class AppConfig {
  final String apiBaseUrl;

  const AppConfig({
    required this.apiBaseUrl,
  });

  factory AppConfig.dev() {
    return const AppConfig(
      apiBaseUrl: 'https://fixi-edge-api.srs2800302.workers.dev/api/v1',
    );
  }
}
