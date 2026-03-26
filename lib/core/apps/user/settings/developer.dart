/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';
import 'dart:convert';

// Custom Code
import '../../../../registry/configuration.dart'; 
import '../../../../registry/app.dart'; 
import '../theme/developer.dart';


class Developer extends StatefulWidget {
  const Developer({super.key});

  @override
  State<Developer> createState() => _DeveloperState();
}

class _DeveloperState extends State<Developer> {
  final TextEditingController _pathController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _machineNameController = TextEditingController();

  List<dynamic> _searchResults = [];

  @override
  void dispose() {
    _pathController.dispose();
    _typeController.dispose();
    _machineNameController.dispose();
    super.dispose();
  }

  // Pass GlobalConfig as an argument to helper methods
  void _executePathSearch(GlobalConfig config) {
    if (_pathController.text.isEmpty) return;
    setState(() {
      _searchResults = configManager.search(
        config.all,
        _pathController.text.trim(),  
      );
    });
  }

  void _executeMetadataFilter(GlobalConfig config) {
    final type = _typeController.text.trim();
    final name = _machineNameController.text.trim();
    if (type.isEmpty || name.isEmpty) return;

    setState(() {
      _searchResults = configManager.filter(
        config.all,
        type,
        name,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = context.configWatch;
    final labels = context.labels['user'] ?? {};
    final developerTheme = context.developerTheme;

    return ExpansionTile(
      title: Text(labels['developer']?['title'] ?? ""),
      leading: Icon(Icons.bug_report, color: developerTheme?.headerIconColor),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubHeader(labels['developer']?['search_path'] ?? "", developerTheme),
              TextField(
                controller: _pathController,
                decoration: InputDecoration(
                  labelText: labels['developer']?['search_path_text'] ?? "",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _executePathSearch(config),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildSubHeader(labels['developer']?['meta_filter'] ?? "", developerTheme),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _typeController,
                      decoration: InputDecoration(
                        labelText: labels['developer']?['meta_filter_type'] ?? "",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _machineNameController,
                      decoration: InputDecoration(
                        labelText: labels['developer']?['meta_filter_name'] ?? "",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _executeMetadataFilter(config),
                icon: const Icon(Icons.filter_alt),
                label: Text(labels['developer']?['meta_filter_button'] ?? ""),
              ),

              const Divider(height: 32),

              Row(
                children: [
                  Text(
                    labels['developer']?['config_system_action_load'] ?? "",
                    style: developerTheme?.sectionLabelStyle,
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final profileId = config.session.id;
                      if (profileId == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("No active profile found to reload.")),
                          );
                        }
                        return;
                      }

                      await configManager.updateProfile(profileId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              labels['developer']?['config_system_help_text'] ?? "Configuration reloaded.",
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.sync),
                    label: Text(labels['developer']?['config_system_button'] ?? ""),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    labels['developer']?['search_results_label'] ?? "",
                    style: developerTheme?.sectionLabelStyle,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _searchResults = [];
                      _pathController.clear();
                      _typeController.clear();
                      _machineNameController.clear();
                    }),
                    child: Text(labels['developer']?['search_results_button'] ?? ""),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: developerTheme?.codeContainerDecoration,
                child: _searchResults.isEmpty
                    ? Text(
                        labels['developer']?['search_results'] ?? "",
                        style: developerTheme?.emptyTextStyle,
                      )
                    : SelectableText(
                        const JsonEncoder.withIndent('  ').convert(_searchResults),
                        style: developerTheme?.codeStyle,
                    
                      ),
              ),

              const SizedBox(height: 16),
              Text(
                labels['developer']?['raw_config'] ?? "",

              ),
              Text(
                config.toJsonString(),
                maxLines: 3,
                style: developerTheme?.rawConfigStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubHeader(String text, DeveloperThemeExtension? theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: theme?.subHeaderStyle,
      ),
    );
  }
}