/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 


class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Custom HttpOverrides to bypass SSL certificate validation for local development
class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? securityContext) {
    return super.createHttpClient(securityContext)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class EndpointRequests {
  final String baseUrl;
  final Map<String, String>? defaultHeaders;
  final Duration timeout;
  final bool allowBadCertificates;

  late http.Client _httpClient;

  EndpointRequests({
    required this.baseUrl,
    this.defaultHeaders,
    this.timeout = const Duration(seconds: 30),
    bool? allowBadCertificates,
  }) : allowBadCertificates = allowBadCertificates ?? _getAllowBadCertificates() {
    _httpClient = http.Client();
    
    if (this.allowBadCertificates) {
      HttpOverrides.global = _MyHttpOverrides();
      debugPrint('SSL Certificate validation disabled for: $baseUrl');
    }
  }

  /// Static helper to read environment variables
  static bool _getAllowBadCertificates() {
    final envValue = dotenv.env['REST_API_APP_SERVICE_DEV'] ?? 'false';
    return envValue.toLowerCase() == 'true';
  }

  /// Helper to combine a Base URL and a Route safely
  Uri _buildUri(String? customUrl, String endpoint) {
    final base = customUrl ?? baseUrl;
    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$cleanBase$cleanEndpoint');
  }

  // --- STANDARD HTTP METHODS ---

  Future<http.Response> get(String endpoint, {String? customUrl, Map<String, String>? headers}) async {
    try {
      final url = _buildUri(customUrl, endpoint);
      final mergedHeaders = {...?defaultHeaders, ...?headers};
      final response = await _httpClient.get(url, headers: mergedHeaders).timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<http.Response> post(String endpoint, {String? customUrl, Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      final url = _buildUri(customUrl, endpoint);
      final mergedHeaders = {'Content-Type': 'application/json', ...?defaultHeaders, ...?headers};
      final response = await _httpClient.post(
        url,
        headers: mergedHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<http.Response> put(String endpoint, {String? customUrl, Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      final url = _buildUri(customUrl, endpoint);
      final mergedHeaders = {'Content-Type': 'application/json', ...?defaultHeaders, ...?headers};
      final response = await _httpClient.put(
        url,
        headers: mergedHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<http.Response> delete(String endpoint, {String? customUrl, Map<String, String>? headers}) async {
    try {
      final url = _buildUri(customUrl, endpoint);
      final mergedHeaders = {...?defaultHeaders, ...?headers};
      final response = await _httpClient.delete(url, headers: mergedHeaders).timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- JSON WRAPPERS ---

  Future<Map<String, dynamic>> getJson(String endpoint, {String? customUrl, Map<String, String>? headers}) async {
    final response = await get(endpoint, customUrl: customUrl, headers: headers);
    return _parseJson(response);
  }

  Future<Map<String, dynamic>> postJson(String endpoint, {String? customUrl, Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final response = await post(endpoint, customUrl: customUrl, body: body, headers: headers);
    return _parseJson(response);
  }

  Future<Map<String, dynamic>> putJson(String endpoint, {String? customUrl, Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final response = await put(endpoint, customUrl: customUrl, body: body, headers: headers);
    return _parseJson(response);
  }

  Future<Map<String, dynamic>> deleteJson(String endpoint, {String? customUrl, Map<String, String>? headers}) async {
    final response = await delete(endpoint, customUrl: customUrl, headers: headers);
    return _parseJson(response);
  }

  Future<List<dynamic>> getJsonList(String endpoint, {String? customUrl, Map<String, String>? headers}) async {
    final response = await get(endpoint, customUrl: customUrl, headers: headers);
    return _parseJsonList(response);
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return response;
    throw ApiException('Request failed: ${response.reasonPhrase}', response.statusCode);
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    if (error is SocketException) return ApiException('No internet connection');
    return ApiException('Unexpected error: ${error.toString()}');
  }

  Map<String, dynamic> _parseJson(http.Response response) => jsonDecode(response.body);
  List<dynamic> _parseJsonList(http.Response response) => jsonDecode(response.body);

  void close() => _httpClient.close();
}