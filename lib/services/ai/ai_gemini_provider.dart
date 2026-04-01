/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import '../resources.dart';
import '../configuration/active_configuration.dart';
import '../endpoint_requests.dart';

/// A service class to interact with a generic AI chat API.
class AiGeminiProvider {
  Future<String> getResponse(String prompt) async {
    try {
      final aiConfig = ActiveConfiguration.config.ai;
      final apiKey = aiConfig.apiKey;
      final model = aiConfig.model;
      final apiUrl = aiConfig.apiUrl;

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('AI API Key is missing.');
      }

      if (apiUrl == null || apiUrl.isEmpty) {
        throw Exception('AI API URL is missing.');
      }

      final endpointRequests = EndpointRequests(baseUrl: apiUrl);

      try {
        // This implementation is based on Google's Gemini API.
        // Example curl:
        // curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent" \
        // -H 'Content-Type: application/json' \
        // -H 'X-goog-api-key: YOUR_API_KEY' \
        // -d '{"contents": [{"parts": [{"text": "Explain how AI works"}]}]}'

        final endpoint = '$model';
        final data = await endpointRequests.postJson(
          endpoint,
          headers: {
            // The Gemini API uses an API key in the 'x-goog-api-key' header.
            'X-goog-api-key': apiKey,
          },
          body: {
            // The body structure for the Gemini API.
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          },
        );

        // Parse the Gemini API response.
        if (data.containsKey('candidates') &&
            (data['candidates'] as List).isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate.containsKey('content') &&
              candidate['content'].containsKey('parts') &&
              (candidate['content']['parts'] as List).isNotEmpty) {
            return candidate['content']['parts'][0]['text'].trim();
          }
        }

        // Handle cases where the API returns an error within a 2xx response.
        if (data.containsKey('error')) {
          final error = data['error'];
          throw ApiException(
              'AI service error: ${error['message']}', error['code']);
        }

        throw Exception('Failed to parse AI response or response was empty.');
      } finally {
        endpointRequests.close();
      }
    } catch (e, stack) {
      GlobalResources().logStackTraceError(e, stack);
      rethrow;
    }
  }
}