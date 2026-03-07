import 'package:flutter/foundation.dart';

@immutable
class ProductReviewModel {
  final String name;
  final int rating;
  final String text;
  final bool isVerified;
  final int daysAgo;

  const ProductReviewModel({
    required this.name,
    required this.rating,
    required this.text,
    required this.isVerified,
    required this.daysAgo,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String get timeAgo {
    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';
    if (daysAgo < 7) return '$daysAgo days ago';
    if (daysAgo < 14) return '1 week ago';
    if (daysAgo < 30) return '${daysAgo ~/ 7} weeks ago';
    final months = daysAgo ~/ 30;
    return '$months month${months > 1 ? 's' : ''} ago';
  }
}
