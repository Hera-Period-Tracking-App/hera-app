import 'dart:convert';

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

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    String? bearerToken,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final response = await _client.get(
      uri,
      headers: _headers(bearerToken: bearerToken),
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
    final response = await _client.post(
      uri,
      headers: _headers(bearerToken: bearerToken),
      body: jsonEncode(body),
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
    final response = await _client.put(
      uri,
      headers: _headers(bearerToken: bearerToken),
      body: jsonEncode(body),
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
    final response = await _client.delete(
      uri,
      headers: _headers(bearerToken: bearerToken),
      body: jsonEncode(body),
    );

    return _decodeResponse(response, uri: uri);
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
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? body;
  final Uri? uri;
  final String? rawBody;

  @override
  String toString() {
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
