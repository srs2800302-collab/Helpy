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
          '1096903651505-plim8k4colk6j0343u028qeim2fcoq1a.apps.googleusercontent.com',
    );
  }
}
