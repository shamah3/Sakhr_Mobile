// lib/screen/home/components/custom_status_bar.dart
import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:intl/intl.dart';

class CustomStatusBar extends StatefulWidget {
  const CustomStatusBar({super.key});

  @override
  State<CustomStatusBar> createState() => _CustomStatusBarState();
}

class _CustomStatusBarState extends State<CustomStatusBar> {
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    // Update every minute
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (!mounted) return false;
      setState(() {
        _timeString = _formatDateTime(DateTime.now());
      });
      return true;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_timeString, style: const TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
          Row(
            children: const [
              Icon(Icons.signal_cellular_alt_rounded, size: 18, color: kTextLightColor),
              SizedBox(width: 6),
              Icon(Icons.wifi, size: 18, color: kTextLightColor),
              SizedBox(width: 6),
              Icon(Icons.battery_full, size: 18, color: kTextLightColor),
            ],
          ),
        ],
      ),
    );
  }
}
