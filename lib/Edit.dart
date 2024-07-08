import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditExpense {
  static Future<void> editExpense(
      BuildContext context,
      Map<String, dynamic> expense,
      Function(Map<String, dynamic> updatedExpense) onEdit) async {
    TextEditingController categoryController =
        TextEditingController(text: expense['category']);
    TextEditingController amountController =
        TextEditingController(text: expense['amount'].toString());
    TextEditingController dateController =
        TextEditingController(text: expense['date']);

    // Ensure context is valid before showing dialog
    if (!Navigator.of(context).canPop()) {
      return; // Return if context is not valid
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                // Prepare updated expense data
                Map<String, dynamic> updatedExpense = {
                  'id': expense['id'], // Ensure ID is maintained
                  'category': categoryController.text,
                  'amount': double.parse(amountController.text),
                  'date': dateController.text,
                };

                try {
                  // Update the expense in Firebase Firestore
                  var user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection(
                            'users') // Adjust to your Firestore structure
                        .doc(user.uid)
                        .collection('expenses')
                        .doc(
                            expense['id']) // Use the document ID of the expense
                        .update(updatedExpense);

                    // Call the onEdit function provided by ExpensesTable
                    onEdit(updatedExpense);

                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    print('User is not authenticated.');
                    // Handle case where user is not authenticated
                  }
                } catch (e) {
                  print('Error updating expense: $e');
                  // Handle error
                }
              },
            ),
          ],
        );
      },
    );
  }
}
