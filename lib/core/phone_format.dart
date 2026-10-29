// Plain helpers for showing phone facts. No Flutter, so they are easy to test.

/// Bytes as "3.9 GB" or "512 MB". Uses 1024 steps, as Android does.
String bytesText(int bytes) {
  if (bytes <= 0) {
    return '0 MB';
  }
  const mb = 1024 * 1024;
  const gb = 1024 * mb;
  if (bytes >= gb) {
    final v = bytes / gb;
    final text = v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text} GB';
  }
  return '${(bytes / mb).round()} MB';
}

/// The size a phone is sold as: 5.6 GB of RAM reads as "6 GB", 119 GB of
/// storage as "128 GB". Rounds up to the next common size.
String marketingSize(int bytes) {
  const gb = 1024 * 1024 * 1024;
  if (bytes <= 0) {
    return '0 GB';
  }
  // Android reports a little less than the real chip, and the system
  // partition takes some of storage, so round up to the next sold size.
  final g = marketingBytes(bytes) / gb;
  return g >= 1024 ? '${(g / 1024).round()} TB' : '${g.round()} GB';
}

/// The size as a number of bytes, matching [marketingSize].
int marketingBytes(int bytes) {
  const gb = 1024 * 1024 * 1024;
  if (bytes <= 0) {
    return 0;
  }
  const sizes = <int>[1, 2, 3, 4, 6, 8, 12, 16, 32, 64, 128, 256, 512, 1024, 2048];
  final g = bytes / gb;
  for (final s in sizes) {
    if (g <= s) {
      return s * gb;
    }
  }
  return bytes;
}

/// Fraction in use, 0 to 1, from the free bytes and the full size.
double usedFraction(int free, int total) {
  if (total <= 0) {
    return 0;
  }
  return (1 - free / total).clamp(0.0, 1.0).toDouble();
}

/// Days, hours and minutes of uptime, for example "2d 7h" or "45m".
String uptimeText(int ms) {
  final totalMin = ms ~/ 60000;
  final d = totalMin ~/ 1440;
  final h = (totalMin % 1440) ~/ 60;
  final m = totalMin % 60;
  if (d > 0) {
    return '${d}d ${h}h';
  }
  if (h > 0) {
    return '${h}h ${m}m';
  }
  return '${m}m';
}
