import 'package:flutter/material.dart';

Color? jobStatusCardColor(String status) {
  switch (status) {
    case 'completed':
      return Colors.grey.shade200;
    case 'cancelled':
      return Colors.red.shade50;
    default:
      return null;
  }
}
