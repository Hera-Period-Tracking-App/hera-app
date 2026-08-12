import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(baseUrl: AppConstants.apiBaseUrl),
);

class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  static const _networkUnavailableMessage =
      'No internet connection. Check your connection and try again.';

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    String? bearerToken,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final response = await _sendJsonRequest(
      uri,
      () => _client.get(
        uri,
        headers: _headers(bearerToken: bearerToken),
      ),
    );

    return _decodeResponse(response, uri: uri);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? queryParameters,
    String? bearerToken,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final response = await _sendJsonRequest(
      uri,
      () => _client.post(
        uri,
        headers: _headers(bearerToken: bearerToken),
        body: jsonEncode(body),
      ),
    );

    return _decodeResponse(response, uri: uri);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? queryParameters,
    String? bearerToken,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final response = await _sendJsonRequest(
      uri,
      () => _client.put(
        uri,
        headers: _headers(bearerToken: bearerToken),
        body: jsonEncode(body),
      ),
    );

    return _decodeResponse(response, uri: uri);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? queryParameters,
    String? bearerToken,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final response = await _sendJsonRequest(
      uri,
      () => _client.delete(
        uri,
        headers: _headers(bearerToken: bearerToken),
        body: jsonEncode(body),
      ),
    );

    return _decodeResponse(response, uri: uri);
  }

  Future<http.Response> _sendJsonRequest(
    Uri uri,
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on SocketException {
      throw ApiException.networkUnavailable(uri: uri);
    } on TimeoutException {
      throw ApiException.networkUnavailable(uri: uri);
    } on http.ClientException catch (error) {
      if (_isNetworkUnavailableClientException(error)) {
        throw ApiException.networkUnavailable(uri: uri);
      }
      rethrow;
    }
  }

  bool _isNetworkUnavailableClientException(http.ClientException error) {
    final message = error.message.toLowerCase();
    return message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('connection failed') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('connection closed') ||
        message.contains('no address associated with hostname');
  }

  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    if (baseUrl.trim().isEmpty) {
      throw const ApiException(
        message:
            'API_BASE_URL is not configured. Pass --dart-define=API_BASE_URL=https://your-api.example.com',
      );
    }

    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '$normalizedBaseUrl$normalizedPath',
    ).replace(queryParameters: queryParameters?.isEmpty ?? true ? null : queryParameters);
  }

  Map<String, String> _headers({String? bearerToken}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (bearerToken != null && bearerToken.isNotEmpty)
        'Authorization': 'Bearer $bearerToken',
    };
  }

  Map<String, dynamic> _decodeResponse(
    http.Response response, {
    required Uri uri,
  }) {
    final hasBody = response.bodyBytes.isNotEmpty;
    final rawBody = hasBody ? utf8.decode(response.bodyBytes) : '';
    final decoded = hasBody ? _tryDecodeJson(rawBody) : <String, dynamic>{};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractMessage(decoded),
        body: decoded is Map<String, dynamic> ? decoded : null,
        uri: uri,
        rawBody: rawBody,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{'data': decoded};
  }

  String _extractMessage(Object? decoded) {
    if (decoded is Map<String, dynamic>) {
      for (final key in const ['message', 'error', 'title', 'detail']) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
    }

    return 'Request failed.';
  }

  Object? _tryDecodeJson(String rawBody) {
    try {
      return jsonDecode(rawBody);
    } catch (_) {
      return rawBody;
    }
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.body,
    this.uri,
    this.rawBody,
    this.isNetworkUnavailable = false,
    this.isSyncKeyUnavailable = false,
  });

  const ApiException.networkUnavailable({Uri? uri})
      : message = ApiClient._networkUnavailableMessage,
        statusCode = null,
        body = null,
        rawBody = null,
        uri = uri,
        isNetworkUnavailable = true,
        isSyncKeyUnavailable = false;

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? body;
  final Uri? uri;
  final String? rawBody;
  final bool isNetworkUnavailable;
  final bool isSyncKeyUnavailable;

  @override
  String toString() {
    if (isNetworkUnavailable) {
      return message;
    }

    if (statusCode == null && uri == null) {
      return message;
    }

    final statusText = statusCode == null ? '' : '[$statusCode] ';
    final uriText = uri == null ? '' : ' ${uri.toString()}';
    final bodyText =
        body == null || body!.isEmpty ? '' : ' body=${jsonEncode(body)}';
    final rawBodyText = (rawBody == null || rawBody!.isEmpty || bodyText.isNotEmpty)
        ? ''
        : ' rawBody=$rawBody';
    return '$statusText$message$uriText$bodyText$rawBodyText'.trim();
  }
}
