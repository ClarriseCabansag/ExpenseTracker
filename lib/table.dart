import 'package:flutter/material.dart';
import 'edit.dart'; // Import the edit.dart file

class ExpensesTable extends StatefulWidget {
  final List<Map<String, dynamic>> expenses;
  final double totalAmount;
  final Future<void> Function(Map<String, dynamic> expense) onDelete;
  final Future<void> Function(Map<String, dynamic> expense) onEdit;

  ExpensesTable({
    required this.expenses,
    required this.totalAmount,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _ExpensesTableState createState() => _ExpensesTableState();
}

class _ExpensesTableState extends State<ExpensesTable> {
  void handleEditExpense(Map<String, dynamic> updatedExpense) {
    setState(() {
      // Find the index of the edited expense in the list
      int index = widget.expenses.indexWhere((expense) =>
          expense['id'] == updatedExpense['id']); // Assuming 'id' is unique

      if (index != -1) {
        // Replace the old expense with the updated one
        widget.expenses[index] = updatedExpense;
      }
    });
  }

  void handleDeleteExpense(Map<String, dynamic> expense) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed) {
      await widget.onDelete(expense);
      setState(() {
        widget.expenses.removeWhere((e) => e['id'] == expense['id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.fromRGBO(181, 158, 206, 1.0), // Violet background color
        ),
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Expenses Table',
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.0),
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.9, // Adjust the width as needed
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Center(child: Text('Category')),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Center(child: Text('Amount')),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Center(child: Text('Date')),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Center(child: Text('Actions')),
                          numeric: false,
                        ), // New column for actions
                      ],
                      columnSpacing: 20.0,
                      dataRowHeight: 60.0,
                      dividerThickness: 2.0,
                      rows: widget.expenses.map((expense) {
                        return DataRow(cells: [
                          DataCell(Center(child: Text(expense['category']))),
                          DataCell(
                              Center(child: Text('₱${expense['amount']}'))),
                          DataCell(Center(child: Text(expense['date']))),
                          DataCell(
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      // Call EditExpense.editExpense to edit the expense
                                      EditExpense.editExpense(
                                        context,
                                        expense,
                                        handleEditExpense,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      handleDeleteExpense(expense);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Total Amount Spent: ₱${widget.totalAmount}',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
