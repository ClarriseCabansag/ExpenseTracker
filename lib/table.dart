import 'package:flutter/material.dart';

class ExpensesTable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Expenses Table',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.0),
          Container(
            height: 300.0, // Fixed height for scrollable area
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')), // New column for actions
                ],
                columnSpacing: 20.0,
                dataRowHeight: 60.0,
                dividerThickness: 2.0,
                rows: expenses.map((expense) {
                  return DataRow(cells: [
                    DataCell(Text(expense['category'])),
                    DataCell(Text('₱${expense['amount']}')),
                    DataCell(Text(expense['date'])),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Handle edit action
                            onEdit(expense);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Handle delete action
                            onDelete(expense);
                          },
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Total Amount Spent: ₱$totalAmount',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
