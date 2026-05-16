/// Formats a [DateTime] as a human-readable relative
/// timestamp (e.g. "2 min ago", "Yesterday").
String formatRelativeTime(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  if (diff.inSeconds < 60) {
    return 'Just now';
  } else if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return '$m min ago';
  } else if (diff.inHours < 24) {
    final h = diff.inHours;
    return '$h ${h == 1 ? 'hour' : 'hours'} ago';
  } else if (diff.inDays == 1) {
    return 'Yesterday';
  } else if (diff.inDays < 7) {
    final d = diff.inDays;
    return '$d days ago';
  } else {
    final d = diff.inDays;
    final weeks = d ~/ 7;
    return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  }
}
