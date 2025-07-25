import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendingChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final DateTime? lastUpdated;

  const SpendingChart({
    super.key,
    required this.categoryTotals,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lastUpdated != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Last updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(lastUpdated!)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ...categoryTotals.entries.map((entry) {
          final percent = total > 0 ? (entry.value / total) : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${entry.value.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}