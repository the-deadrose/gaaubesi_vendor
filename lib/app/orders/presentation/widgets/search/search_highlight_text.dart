import 'package:flutter/material.dart';

/// Utility for highlighting text in search results.
class SearchHighlightText {
  /// Creates a [TextSpan] with highlighted query matches.
  static TextSpan highlight({
    required String text,
    required String query,
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    final defaultNormalStyle =
        normalStyle ?? const TextStyle(color: Colors.black);
    final defaultHighlightStyle =
        highlightStyle ??
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue);

    if (query.isEmpty) {
      return TextSpan(text: text, style: defaultNormalStyle);
    }

    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        matches.add(
          TextSpan(text: text.substring(start), style: defaultNormalStyle),
        );
        break;
      }

      if (index > start) {
        matches.add(
          TextSpan(
            text: text.substring(start, index),
            style: defaultNormalStyle,
          ),
        );
      }

      matches.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: defaultHighlightStyle,
        ),
      );

      start = index + query.length;
    }

    return TextSpan(children: matches);
  }
}

/// Widget that displays text with highlighted search matches.
class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? normalStyle;
  final TextStyle? highlightStyle;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.normalStyle,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: SearchHighlightText.highlight(
        text: text,
        query: query,
        normalStyle: normalStyle,
        highlightStyle: highlightStyle,
      ),
    );
  }
}
