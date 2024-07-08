import 'package:flutter/material.dart';

class DeleteExpense {
  static Future<void> deleteExpense(
      BuildContext context,
      Map<String, dynamic> expense,
      Function(Map<String, dynamic> expense) onDelete) async {
    // Example: Show a confirmation dialog for deletion
    // Replace with your custom delete functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Call the onDelete function provided by ExpensesTable
                onDelete(expense);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
