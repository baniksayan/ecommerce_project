class TobaccoKeywordMatcher {
  TobaccoKeywordMatcher._();

  static const List<String> _phrases = <String>[
    // Generic terms
    'tobacco',
    'cigarette',
    'cigarettes',
    'smoke',
    'smoking',
    // Brands / common queries
    'wills navy cut',
    'wills navy cut silver',
    'wills navy cut kings',
    'gold flake',
    'gold flake kings',
    'classic',
    'classic milds',
    'four square',
    'red and white',
    'red & white',
    'cavanders',
    'marlboro',
    'silk cut',
    'tipper',
    'charminar',
    'small gold flake',
    // Policy terms from age restriction policy screen
    'bidi',
    'bidis',
    'khaini',
    'gutkha',
    'zarda',
    'nicotine',
  ];

  static bool isTobaccoQuery(String query) {
    final q = _normalize(query);
    if (q.isEmpty) return false;

    for (final phrase in _phrases) {
      final p = _normalize(phrase);
      if (p.isEmpty) continue;
      if (q.contains(p)) return true;
    }

    return false;
  }

  static String _normalize(String input) {
    var s = input.trim().toLowerCase();
    if (s.isEmpty) return '';

    // Preserve "&" as a searchable token by mapping to "and".
    s = s.replaceAll('&', ' and ');

    // Remove most punctuation but keep spaces for phrase matching.
    s = s.replaceAll(RegExp(r"[^a-z0-9\s]+"), ' ');

    // Collapse whitespace.
    s = s.replaceAll(RegExp(r'\s+'), ' ');

    return s.trim();
  }
}
