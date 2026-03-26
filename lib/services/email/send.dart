/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Send {
  final String host = dotenv.env['SMTP_HOST'] ?? '';
  final int port = int.tryParse(dotenv.env['SMTP_PORT'] ?? '587') ?? 587;
  final String username = dotenv.env['SMTP_USERNAME'] ?? '';
  final String password = dotenv.env['SMTP_PASSWORD'] ?? '';
  final String from = dotenv.env['SMTP_FROM'] ?? '';

  SmtpServer get _smtpServer {
    return SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
      ignoreBadCertificate: false,
      ssl: false,
      allowInsecure: true,
    );
  }

  /// Sends an email.
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final message = Message()
      ..from = Address(from)
      ..recipients.add(to)
      ..subject = subject
      ..text = body;

    try {
      await send(message, _smtpServer);
      debugPrint('error. messsage');
    } on MailerException catch (e) {
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
      rethrow;
    }
  }
}
