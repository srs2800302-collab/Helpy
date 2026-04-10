import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clear();
}

class FileTokenStorage implements TokenStorage {
  static const _fileName = 'fixi_auth_tokens.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, dynamic>> _readJson() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return {};
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return {};
      }

      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeJson(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(json.encode(data));
  }

  @override
  Future<void> saveAccessToken(String token) async {
    final data = await _readJson();
    data['accessToken'] = token;
    await _writeJson(data);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    final data = await _readJson();
    data['refreshToken'] = token;
    await _writeJson(data);
  }

  @override
  Future<String?> getAccessToken() async {
    final data = await _readJson();
    return data['accessToken'] as String?;
  }

  @override
  Future<String?> getRefreshToken() async {
    final data = await _readJson();
    return data['refreshToken'] as String?;
  }

  @override
  Future<void> clear() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
