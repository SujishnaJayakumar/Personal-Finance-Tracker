import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlySummaryScreen extends StatelessWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: expensesRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            double total = 0;
            final Map<String, double> categoryTotals = {};
            for (var doc in docs) {
              final amount = doc['amount'] as double;
              final category = doc['category'] ?? 'Other';
              total += amount;
              categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Spent: ₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ...categoryTotals.entries.map((entry) => Text('${entry.key}: ₹${entry.value.toStringAsFixed(2)}')),
              ],
            );
          },
        ),
      ),
    );
  }
}