class AppConfig {
  final String apiBaseUrl;
  final String googleServerClientId;

  const AppConfig({
    required this.apiBaseUrl,
    required this.googleServerClientId,
  });

  factory AppConfig.dev() {
    return const AppConfig(
      apiBaseUrl: 'https://fixi-edge-api.srs2800302.workers.dev/api/v1',
      googleServerClientId:
          '1096903651505-00uj9fa78pkgstt07b3qd7jvo6qrvc13.apps.googleusercontent.com',
    );
  }
}
