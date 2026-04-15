import 'dart:io';

abstract class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> clearAccessToken();

  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();

  Future<void> clearAll();
}

class FileTokenStorage implements TokenStorage {
  final File _accessTokenFile;
  final File _refreshTokenFile;

  FileTokenStorage({
    String accessTokenPath = 'fixi_access_token',
    String refreshTokenPath = 'fixi_refresh_token',
  })  : _accessTokenFile = File('${Directory.systemTemp.path}/$accessTokenPath'),
        _refreshTokenFile = File('${Directory.systemTemp.path}/$refreshTokenPath');

  @override
  Future<void> saveAccessToken(String token) async {
    await _accessTokenFile.parent.create(recursive: true);
    await _accessTokenFile.writeAsString(token, flush: true);
  }

  @override
  Future<String?> getAccessToken() async {
    if (!await _accessTokenFile.exists()) return null;

    final value = await _accessTokenFile.readAsString();
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> clearAccessToken() async {
    if (await _accessTokenFile.exists()) {
      await _accessTokenFile.delete();
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _refreshTokenFile.parent.create(recursive: true);
    await _refreshTokenFile.writeAsString(token, flush: true);
  }

  @override
  Future<String?> getRefreshToken() async {
    if (!await _refreshTokenFile.exists()) return null;

    final value = await _refreshTokenFile.readAsString();
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> clearRefreshToken() async {
    if (await _refreshTokenFile.exists()) {
      await _refreshTokenFile.delete();
    }
  }

  @override
  Future<void> clearAll() async {
    await clearAccessToken();
    await clearRefreshToken();
  }
}
