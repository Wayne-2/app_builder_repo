import 'dart:math';
import 'package:intl/intl.dart';

class LagosIdGenerator {
  static final Random _random = Random();
  
  static const int randomPartLength = 10;
  static const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static String generate() {
    final DateTime lagosTime = DateTime.now().toUtc().add(const Duration(hours: 1));

    final String prefix = DateFormat('ddMMyyyyHHmm').format(lagosTime);
    final String suffix = List.generate(
      randomPartLength,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();

    return prefix + suffix;
  }
}