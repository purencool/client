/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:flutter/material.dart';

/// Defines custom theme properties for developer-specific UI elements.
/// This allows for consistent styling of code blocks and containers, accessible
/// via `Theme.of(context).extension<DeveloperThemeExtension>()`.
@immutable
class DeveloperThemeExtension extends ThemeExtension<DeveloperThemeExtension> {
  const DeveloperThemeExtension({
    required this.codeStyle,
    required this.codeContainerDecoration,
    required this.headerIconColor,
    required this.subHeaderStyle,
    required this.sectionLabelStyle,
    required this.emptyTextStyle,
    required this.rawConfigStyle,
  });

  /// Creates an instance from a configuration map.
  factory DeveloperThemeExtension.fromConfig(Map<String, dynamic> config) {
    // Helper to parse colors locally.
    Color c(dynamic value) => Color(value is int ? value : 0xFF000000);

    return DeveloperThemeExtension(
      codeStyle: TextStyle(
        color: c(config['codeColor']),
        fontFamily: config['codeFontFamily'] as String?,
        fontSize: (config['codeFontSize'] as num?)?.toDouble(),
      ),
      codeContainerDecoration: BoxDecoration(
        color: c(config['containerColor']),
        borderRadius: BorderRadius.circular(8),
      ),
      headerIconColor: c(config['headerIconColor']),
      subHeaderStyle: TextStyle(
        fontSize: (config['subHeaderFontSize'] as num?)?.toDouble(),
        color: c(config['subHeaderColor']),
        fontWeight: FontWeight.bold,
      ),
      sectionLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      emptyTextStyle: TextStyle(color: c(config['emptyTextColor'])),
      rawConfigStyle: TextStyle(
        fontSize: (config['rawConfigFontSize'] as num?)?.toDouble(),
        color: c(config['rawConfigColor']),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  final TextStyle? codeStyle;
  final BoxDecoration? codeContainerDecoration;
  final Color? headerIconColor;
  final TextStyle? subHeaderStyle;
  final TextStyle? sectionLabelStyle;
  final TextStyle? emptyTextStyle;
  final TextStyle? rawConfigStyle;

  @override
  DeveloperThemeExtension copyWith({
    TextStyle? codeStyle,
    BoxDecoration? codeContainerDecoration,
    Color? headerIconColor,
    TextStyle? subHeaderStyle,
    TextStyle? sectionLabelStyle,
    TextStyle? emptyTextStyle,
    TextStyle? rawConfigStyle,
  }) {
    return DeveloperThemeExtension(
      codeStyle: codeStyle ?? this.codeStyle,
      codeContainerDecoration:
          codeContainerDecoration ?? this.codeContainerDecoration,
      headerIconColor: headerIconColor ?? this.headerIconColor,
      subHeaderStyle: subHeaderStyle ?? this.subHeaderStyle,
      sectionLabelStyle: sectionLabelStyle ?? this.sectionLabelStyle,
      emptyTextStyle: emptyTextStyle ?? this.emptyTextStyle,
      rawConfigStyle: rawConfigStyle ?? this.rawConfigStyle,
    );
  }

  @override
  DeveloperThemeExtension lerp(
    ThemeExtension<DeveloperThemeExtension>? other,
    double t,
  ) {
    if (other is! DeveloperThemeExtension) {
      return this;
    }
    return DeveloperThemeExtension(
      codeStyle: TextStyle.lerp(codeStyle, other.codeStyle, t),
      codeContainerDecoration: BoxDecoration.lerp(
          codeContainerDecoration, other.codeContainerDecoration, t),
      headerIconColor: Color.lerp(headerIconColor, other.headerIconColor, t),
      subHeaderStyle: TextStyle.lerp(subHeaderStyle, other.subHeaderStyle, t),
      sectionLabelStyle: TextStyle.lerp(sectionLabelStyle, other.sectionLabelStyle, t),
      emptyTextStyle: TextStyle.lerp(emptyTextStyle, other.emptyTextStyle, t),
      rawConfigStyle: TextStyle.lerp(rawConfigStyle, other.rawConfigStyle, t),
    );
  }
}

/// Allows accessing the developer theme via `context.developerTheme`.
extension DeveloperThemeExtensionHelper on BuildContext {
  DeveloperThemeExtension? get developerTheme => Theme.of(this).extension<DeveloperThemeExtension>();
}