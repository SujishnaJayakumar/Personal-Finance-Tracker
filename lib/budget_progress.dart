import 'package:flutter/material.dart';

class BudgetProgress extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;

  const BudgetProgress({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final percent = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final overBudget = spent > limit;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$category Budget: ₹${limit.toStringAsFixed(0)}'),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[300],
            color: overBudget ? Colors.red : Colors.green,
          ),
          Text(
            'Spent: ₹${spent.toStringAsFixed(0)}',
            style: TextStyle(color: overBudget ? Colors.red : Colors.black),
          ),
        ],
      ),
    );
  }
}