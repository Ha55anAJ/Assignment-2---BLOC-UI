const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Describes how long ago [time] was, such as "5 min ago" or "2 days ago".
///
/// A `null` [time] means Firestore has not filled in the server timestamp yet,
/// which only happens for an item that was just posted.
String timeAgo(DateTime? time, {DateTime? now}) {
  if (time == null) return 'just now';

  final difference = (now ?? DateTime.now()).difference(time);
  if (difference.inMinutes < 1) return 'just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) {
    return difference.inHours == 1
        ? '1 hour ago'
        : '${difference.inHours} hours ago';
  }
  if (difference.inDays < 7) {
    return difference.inDays == 1
        ? 'yesterday'
        : '${difference.inDays} days ago';
  }
  return formatDate(time);
}

/// Formats [time] as a date, such as "10 Nov 2026".
String formatDate(DateTime time) {
  return '${time.day} ${_months[time.month - 1]} ${time.year}';
}

/// Formats [time] as a date and time, such as "10 Nov 2026, 3:05 PM".
String formatDateTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '${formatDate(time)}, $hour:$minute $period';
}
