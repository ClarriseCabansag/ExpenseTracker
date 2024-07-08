import 'package:flutter/material.dart';
import 'table.dart';

class ExpenseTablePage extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  final double totalAmount;
  final Future<void> Function(Map<String, dynamic> expense) onDelete;
  final Future<void> Function(Map<String, dynamic> expense) onEdit;

  ExpenseTablePage({
    required this.expenses,
    required this.totalAmount,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpensesTable(
          expenses: expenses,
          totalAmount: totalAmount,
          onDelete: onDelete,
          onEdit: onEdit,
        ),
      ),
    );
  }
}
