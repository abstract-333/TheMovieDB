import 'package:themoviedb/configuratoin/configuration.dart';
import 'package:themoviedb/domain/api_client/network_client.dart';

class AuthApiClient {
  final _networkClient = NetworkClient();
  Future<String> auth({
    required String username,
    required String password,
  }) async {
    final token = await _makeToken();
    final validToken = await _validateUser(
      username: username,
      password: password,
      requestToken: token,
    );
    final sessoinId = await _makeSession(requestToken: validToken);
    return sessoinId;
  }

  Future<String> _makeToken() async {
    String parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token = jsonMap['request_token'] as String;
      return token;
    }

    final result = _networkClient.get('/authentication/token/new', parser,
        <String, dynamic>{'api_key': Configuration.apiKey});
    return result;
  }

  Future<String> _validateUser(
      {required String username,
      required String password,
      required String requestToken}) async {
    String parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token = jsonMap['request_token'] as String;
      return token;
    }

    final parmeters = <String, dynamic>{
      'username': username,
      'password': password,
      'request_token': requestToken
    };
    final result = _networkClient.post(
      '/authentication/token/validate_with_login',
      parser,
      parmeters,
      <String, dynamic>{'api_key': Configuration.apiKey},
    );
    return result;
  }

  Future<String> _makeSession({required String requestToken}) async {
    String parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final sessionId = jsonMap['session_id'] as String;
      return sessionId;
    }

    final parmeters = <String, dynamic>{'request_token': requestToken};
    final result = _networkClient.post(
      '/authentication/session/new',
      parser,
      parmeters,
      <String, dynamic>{'api_key': Configuration.apiKey},
    );
    return result;
  }
}
