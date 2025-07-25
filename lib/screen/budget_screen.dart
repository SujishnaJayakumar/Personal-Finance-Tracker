import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Other'];
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (var cat in categories) {
      controllers[cat] = TextEditingController();
    }
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).collection('budgets').get();
    for (var doc in snapshot.docs) {
      controllers[doc.id]?.text = doc['limit'].toString();
    }
  }

  Future<void> saveBudgets() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid).collection('budgets');
    for (var cat in categories) {
      final text = controllers[cat]!.text.trim();
      if (text.isNotEmpty) {
        final limit = double.tryParse(text) ?? 0;
        await ref.doc(cat).set({'limit': limit});
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budgets saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Budgets')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...categories.map((cat) => TextField(
                  controller: controllers[cat],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '$cat Budget'),
                )),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveBudgets, child: const Text('Save Budgets')),
          ],
        ),
      ),
    );
  }
}