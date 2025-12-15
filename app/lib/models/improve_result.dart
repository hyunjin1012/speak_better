class ImproveResult {
  final String improved;
  final Alternatives alternatives;
  final Feedback feedback;

  ImproveResult({
    required this.improved,
    required this.alternatives,
    required this.feedback,
  });

  factory ImproveResult.fromJson(Map<String, dynamic> json) => ImproveResult(
        improved: json['improved'] as String,
        alternatives: Alternatives.fromJson(json['alternatives'] as Map<String, dynamic>),
        feedback: Feedback.fromJson(json['feedback'] as Map<String, dynamic>),
      );
}

class Alternatives {
  final String formal;
  final String casual;
  final String concise;

  Alternatives({
    required this.formal,
    required this.casual,
    required this.concise,
  });

  factory Alternatives.fromJson(Map<String, dynamic> json) => Alternatives(
        formal: json['formal'] as String,
        casual: json['casual'] as String,
        concise: json['concise'] as String,
      );
}

class Feedback {
  final List<String> summary;
  final List<GrammarFix> grammarFixes;
  final List<VocabularyUpgrade> vocabularyUpgrades;
  final FillerWords fillerWords;

  Feedback({
    required this.summary,
    required this.grammarFixes,
    required this.vocabularyUpgrades,
    required this.fillerWords,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) => Feedback(
        summary: (json['summary'] as List).map((e) => e as String).toList(),
        grammarFixes: (json['grammar_fixes'] as List)
            .map((e) => GrammarFix.fromJson(e as Map<String, dynamic>))
            .toList(),
        vocabularyUpgrades: (json['vocabulary_upgrades'] as List)
            .map((e) => VocabularyUpgrade.fromJson(e as Map<String, dynamic>))
            .toList(),
        fillerWords: FillerWords.fromJson(json['filler_words'] as Map<String, dynamic>),
      );
}

class GrammarFix {
  final String from;
  final String to;
  final String why;

  GrammarFix({
    required this.from,
    required this.to,
    required this.why,
  });

  factory GrammarFix.fromJson(Map<String, dynamic> json) => GrammarFix(
        from: json['from'] as String,
        to: json['to'] as String,
        why: json['why'] as String,
      );
}

class VocabularyUpgrade {
  final String from;
  final String to;
  final String why;

  VocabularyUpgrade({
    required this.from,
    required this.to,
    required this.why,
  });

  factory VocabularyUpgrade.fromJson(Map<String, dynamic> json) => VocabularyUpgrade(
        from: json['from'] as String,
        to: json['to'] as String,
        why: json['why'] as String,
      );
}

class FillerWords {
  final int count;
  final List<String> examples;

  FillerWords({
    required this.count,
    required this.examples,
  });

  factory FillerWords.fromJson(Map<String, dynamic> json) => FillerWords(
        count: json['count'] as int,
        examples: (json['examples'] as List).map((e) => e as String).toList(),
      );
}

