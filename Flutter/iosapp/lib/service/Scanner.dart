// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../UIcomponents/ScannerView.dart';

class Scanner {
  static Future<String?> doAction(BuildContext context) async {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ScannerView()),
    );
  }
}
