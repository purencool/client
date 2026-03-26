/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// A utility class for formatting Markdown content and generating a PDF document
/// that can be printed or shared.
///
/// This class parses raw Markdown text, converts it into PDF widgets (handling
/// headers, lists, styling, and basic tables), and manages the print interaction.
class FormatAndPrint {
  /// The title of the document, used for the file name and optional header.
  final String title;

  /// The raw Markdown content to be formatted and printed.
  final String content;

  /// Whether to include the [title] as a header at the top of the PDF page.
  /// Defaults to `false`.
  final bool showTitle;

  /// Optional map of styles to override the default PDF text styles.
  ///
  /// Keys should match the internal style names: 'base', 'bold', 'italic',
  /// 'code', 'link', 'title'.
  final Map<String, dynamic>? styleOverrides;

  /// Creates a [FormatAndPrint] instance.
  FormatAndPrint(this.title, this.content, {this.showTitle = false, this.styleOverrides});

  /// Initiates the print process.
  ///
  /// If printers are available on the system, it opens the system print dialog.
  /// If no printers are found, it generates the PDF and opens the share sheet
  /// (or save dialog) for the file.
  Future<void> print() async {
    final printers = await Printing.listPrinters();
    if (printers.isNotEmpty) {
      await Printing.layoutPdf(
        onLayout: _generatePdf,
        name: title,
      );
    } else {
      await Printing.sharePdf(
        bytes: await _generatePdf(PdfPageFormat.a4),
        filename: '$title.pdf',
      );
    }
  }

  /// Generates the PDF document bytes based on the provided [format].
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontItalic = await PdfGoogleFonts.robotoItalic();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontMono = await PdfGoogleFonts.robotoMonoRegular();

    final styles = <String, dynamic>{
      'base': pw.TextStyle(font: font, fontSize: 12),
      'bold': pw.TextStyle(font: fontBold, fontSize: 12),
      'italic': pw.TextStyle(font: fontItalic, fontSize: 12),
      'code': pw.TextStyle(
          font: fontMono,
          fontSize: 11,
          background:
              const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE0E0E0))),
      'link': pw.TextStyle(
          font: font,
          fontSize: 12,
          color: PdfColors.blue,
          decoration: pw.TextDecoration.underline),
      'title': pw.TextStyle(
          font: fontBold, fontSize: 24, fontWeight: pw.FontWeight.bold),
      'tableBorder': pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      'tableHeader': pw.TextStyle(font: fontBold, fontSize: 12),
    };

    if (styleOverrides != null) {
      styles.addAll(styleOverrides!);
    }

    pw.RichText parseInlineMarkdown(String line, {pw.TextStyle? baseStyle}) {
      final spans = <pw.TextSpan>[];
      final regex =
          RegExp(r'(\*\*(.*?)\*\*|\*(.*?)\*|`(.*?)`|\[(.*?)\]\((.*?)\))');
      int lastIndex = 0;

      for (final match in regex.allMatches(line)) {
        if (match.start > lastIndex) {
          spans.add(pw.TextSpan(text: line.substring(lastIndex, match.start)));
        }

        final boldText = match.group(2);
        final italicText = match.group(3);
        final codeText = match.group(4);
        final linkText = match.group(5);
        final linkUrl = match.group(6);

        if (boldText != null) {
          spans.add(pw.TextSpan(text: boldText, style: styles['bold'] as pw.TextStyle));
        } else if (italicText != null) {
          spans.add(pw.TextSpan(text: italicText, style: styles['italic'] as pw.TextStyle));
        } else if (codeText != null) {
          spans.add(pw.TextSpan(text: codeText, style: styles['code'] as pw.TextStyle));
        } else if (linkText != null && linkUrl != null) {
          spans.add(pw.TextSpan(
              text: linkText,
              style: styles['link'] as pw.TextStyle,
              annotation: pw.AnnotationUrl(linkUrl)));
        }
        lastIndex = match.end;
      }

      if (lastIndex < line.length) {
        spans.add(pw.TextSpan(text: line.substring(lastIndex)));
      }

      return pw.RichText(
          text: pw.TextSpan(style: baseStyle ?? styles['base'] as pw.TextStyle, children: spans));
    }

    List<pw.Widget> buildMarkdownWidgets(String text) {
      final widgets = <pw.Widget>[];
      final lines = text.split('\n');
      int olCounter = 1;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmedLine = line.trimLeft();
        final leadingSpaces = line.length - trimmedLine.length;
        final indent = (leadingSpaces / 2) * 10.0;

        final isOl = RegExp(r'^\d+\. ').hasMatch(trimmedLine);
        final prevLineIsOl =
            i > 0 && RegExp(r'^\d+\. ').hasMatch(lines[i - 1].trimLeft());

        if (!isOl || !prevLineIsOl) {
          olCounter = 1;
        }

        if (line.startsWith('# ')) {
          widgets.add(pw.Header(
              level: 0, child: parseInlineMarkdown(line.substring(2))));
        } else if (line.startsWith('## ')) {
          widgets.add(pw.Header(
              level: 1, child: parseInlineMarkdown(line.substring(3))));
        } else if (line.startsWith('### ')) {
          widgets.add(pw.Header(
              level: 2, child: parseInlineMarkdown(line.substring(4))));
        } else if (trimmedLine.startsWith('* ') || trimmedLine.startsWith('- ')) {
          widgets.add(pw.Padding(
            padding: pw.EdgeInsets.only(left: indent),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      width: 20, child: pw.Text('•', style: styles['bold'] as pw.TextStyle)),
                  pw.Expanded(
                      child: parseInlineMarkdown(trimmedLine.substring(2)))
                ]),
          ));
        } else if (isOl) {
          widgets.add(pw.Padding(
            padding: pw.EdgeInsets.only(left: indent),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      width: 20,
                      child: pw.Text('$olCounter.', style: styles['bold'] as pw.TextStyle)),
                  pw.Expanded(
                      child: parseInlineMarkdown(
                          trimmedLine.substring(trimmedLine.indexOf('. ') + 2)))
                ]),
          ));
          olCounter++;
        } else if (line.trim() == '---') {
          widgets.add(pw.Divider());
        } else if (line.trim().startsWith('|')) {
          // This is the start of a table.
          final tableLines = <String>[];
          int tableEndIndex = i;

          // Collect all table lines
          while (tableEndIndex < lines.length &&
              lines[tableEndIndex].trim().startsWith('|')) {
            tableLines.add(lines[tableEndIndex]);
            tableEndIndex++;
          }

          // The second row must be a separator
          if (tableLines.length < 2 || !tableLines[1].trim().contains('---')) {
            // This is not a valid table, so we fall back to rendering as text
            for (final tableLine in tableLines) {
              widgets.add(pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: parseInlineMarkdown(tableLine)));
            }
          } else {
            // It's a valid table, let's build it.
            final tableRows = <pw.TableRow>[];

            // Header
            final headerLine = tableLines[0];
            final headerCells = headerLine.trim().substring(1, headerLine.trim().length - 1).split('|');
            tableRows.add(pw.TableRow(
              children: headerCells.map((cell) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: parseInlineMarkdown(cell.trim(), baseStyle: styles['tableHeader'] as pw.TextStyle),
                );
              }).toList(),
            ));

            // Data rows
            for (int rowIndex = 2; rowIndex < tableLines.length; rowIndex++) {
              final rowLine = tableLines[rowIndex];
              final rowCells = rowLine.trim().substring(1, rowLine.trim().length - 1).split('|');
              
              if (rowCells.length == headerCells.length) {
                  tableRows.add(pw.TableRow(
                      children: rowCells.map((cell) {
                          return pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: parseInlineMarkdown(cell.trim()),
                          );
                      }).toList(),
                  ));
              }
            }
            
            widgets.add(pw.Table(
              border: styles['tableBorder'] as pw.TableBorder,
              children: tableRows,
            ));
          }

          i = tableEndIndex - 1;
        } else if (line.trim().isNotEmpty) {
          widgets.add(pw.Padding(padding: const pw.EdgeInsets.only(bottom: 5), child: parseInlineMarkdown(line)));
        } else {
          widgets.add(pw.SizedBox(height: 5));
        }
      }
      return widgets;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) => [
          if (showTitle)
            pw.Header(
              level: 0,
              child: pw.Text(title,
                  style: styles['title'] as pw.TextStyle),
            ),
          ...buildMarkdownWidgets(content),
        ],
      ),
    );
    return await doc.save();
  }
}