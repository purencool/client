/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'ai_gemini_provider.dart';

/// A service class to interact with a generic AI chat API.
class Ai{
  
  Future<String> _getGeminiResponse(String prompt) async {
    return AiGeminiProvider().getResponse(prompt);
  }

  Future<String> getResponse(String prompt) async {
    return  _getGeminiResponse(prompt);
  }
}

final GlobalKey<NavigatorState> aiKey = GlobalKey<NavigatorState>();

/// A service class to interact with a generic AI chat API.
class AiRequest { 
 Future<String> getResponse(String prompt) async {
    return await Ai().getResponse(prompt);
  }
}

/// A global instance of the AiRequest class.
final aiRequests =  AiRequest();