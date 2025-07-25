import 'package:finance_tracker/budget_progress.dart';
import 'package:finance_tracker/screen/spending_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'budget_screen.dart';
import 'monthly_summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String selectedCategory = 'Food';
  final categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Other'];

  Future<void> addExpense() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .add({
      'amount': double.parse(amountController.text),
      'note': noteController.text,
      'category': selectedCategory,
      'type': 'expense',
      'date': Timestamp.now(),
    });
    amountController.clear();
    noteController.clear();
  }

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

    final budgetsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('budgets');

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Expense Input
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCategory = val!),
            ),
            ElevatedButton(
              onPressed: addExpense,
              child: const Text('Add Expense'),
            ),

            const SizedBox(height: 20),

            // Navigation Buttons
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
              child: const Text('Set Budgets'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const MonthlySummaryScreen())),
              child: const Text('View Monthly Summary'),
            ),

            const Divider(),

            // Expense Summary
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: expensesRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  double total = 0;
                  DateTime? lastUpdated;
                  final Map<String, double> categoryTotals = {};

                  for (var doc in docs) {
                    final amount = doc['amount'] as double;
                    final category = doc['category'] ?? 'Other';
                    final timestamp = doc['date'] as Timestamp;
                    final date = timestamp.toDate();

                    if (lastUpdated == null || date.isAfter(lastUpdated)) {
                      lastUpdated = date;
                    }

                    total += amount;
                    categoryTotals[category] =
                        (categoryTotals[category] ?? 0) + amount;
                  }

                  return FutureBuilder<QuerySnapshot>(
                    future: budgetsRef.get(),
                    builder: (context, budgetSnap) {
                      final Map<String, double> budgetLimits = {};
                      if (budgetSnap.hasData) {
                        for (var doc in budgetSnap.data!.docs) {
                          budgetLimits[doc.id] = doc['limit'] as double;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Expenses: ₹${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          SpendingChart(
                            categoryTotals: categoryTotals,
                            lastUpdated: lastUpdated,
                          ),
                          const SizedBox(height: 10),
                          ...categoryTotals.entries.map((entry) {
                            final category = entry.key;
                            final spent = entry.value;
                            final limit = budgetLimits[category] ?? 0;
                            return BudgetProgress(
                              category: category,
                              spent: spent,
                              limit: limit,
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}