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
      appBar: AppBar(
        title: Text('Expenses Table'), // Set app name here
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.fromRGBO(181, 158, 206, 1.0), // Violet background color
        ),
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text('Category'),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text('Amount'),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text('Date'),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text('Actions'),
                        numeric: false,
                      ),
                    ],
                    columnSpacing: 10.0,
                    dataRowHeight: 60.0,
                    dividerThickness: 2.0,
                    rows: widget.expenses.map((expense) {
                      return DataRow(cells: [
                        DataCell(
                          Flexible(
                            child: Text(
                              expense['category'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Flexible(
                            child: Text(
                              '₱${expense['amount']}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                        DataCell(
                          Flexible(
                            child: Text(
                              expense['date'],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
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
                      ]);
                    }).toList(),
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
