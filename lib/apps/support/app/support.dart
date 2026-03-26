/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

// Custom
import '../../../registry/app.dart'; 

/// Custom app container layout widgets.
import '../../../services/email/send.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _EmailFormState();
}

class _EmailFormState extends State<Support> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _sending = false;
  bool _checkingSpelling = false;

  @override
  void initState() {
    super.initState();
    keybindings.pushKey(_scaffoldKey);
  }



  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // It's a good practice to grab the ScaffoldMessenger before an async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _sending = true);
    try {
      final send = Send();
      await send.sendEmail(
        to: _emailController.text.trim(),
        subject: _subjectController.text.trim(),
        body: _bodyController.text.trim(),
      );

      if (!mounted) return;

      // Provide success feedback, which is crucial for accessibility.
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Email sent successfully!')),
      );

      // Reset the form on success.
      _formKey.currentState?.reset();
      _emailController.clear();
      _subjectController.clear();
      _bodyController.clear();
    } catch (e) {
      if (!mounted) return;
      // Make the error SnackBar more accessible by adding a dismiss action.
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Failed to send email: $e'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => scaffoldMessenger.hideCurrentSnackBar(),
        ),
      ));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _spellCheck() async {
    if (_bodyController.text.trim().isEmpty) return;

    setState(() => _checkingSpelling = true);
    try {
      // TODO: Implement AI spell check logic here.
      // final corrected = await AiService.spellCheck(_bodyController.text);
      // _bodyController.text = corrected;
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spell check failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _checkingSpelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = context.labels['support'] ?? {};

    // Permission check
    if (!context.isAllowed('support')) {
      return const AccessDenied();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(labels['title'] ?? "")),
      drawer: const AppMenu(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                 Semantics(
                  header: true,
                  child: Text( 'Send Support Email'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a subject'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    suffixIcon: IconButton(
                      icon: _checkingSpelling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.spellcheck),
                      onPressed: _checkingSpelling ? null : _spellCheck,
                      tooltip: 'AI Spell Check',
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a message'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  child: _sending
                      ? Semantics(
                          label: 'Sending',
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
