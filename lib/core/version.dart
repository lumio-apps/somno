/// Splits "v1.2.3", "1.2.3+4" or "1.2.3-beta" into [1, 2, 3].
List<int> parseVersion(String version) {
  var v = version.trim();
  if (v.startsWith('v') || v.startsWith('V')) {
    v = v.substring(1);
  }
  final core = v.split(RegExp(r'[+-]')).first;
  if (core.isEmpty) {
    return const <int>[0];
  }
  return core.split('.').map((part) => int.tryParse(part) ?? 0).toList();
}

/// True when [latest] is a higher version than [current].
bool isNewerVersion(String latest, String current) {
  final a = parseVersion(latest);
  final b = parseVersion(current);
  final length = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < length; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) {
      return x > y;
    }
  }
  return false;
}
