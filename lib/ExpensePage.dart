import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'budget.dart';
import 'category.dart';
import 'table.dart';
import 'main.dart'; // Assuming you have a login.dart file for your login page
import 'History.dart';

class ExpenseTrackerPage extends StatefulWidget {
  @override
  _ExpenseTrackerPageState createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _budgetController = TextEditingController();
  List<Map<String, dynamic>> _expenses = [];
  String _weeklyBudget = '';
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot budgetDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budget')
          .doc('weeklyBudget')
          .get();
      if (budgetDoc.exists) {
        setState(() {
          _weeklyBudget = budgetDoc.get('amount').toString();
        });
      }

      QuerySnapshot expenseSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .get();
      setState(() {
        _expenses = expenseSnapshot.docs.map((doc) {
          return {
            'id': doc.id, // Store the document ID
            'category': doc.get('category'),
            'amount': doc.get('amount').toString(),
            'date': doc.get('date'),
          };
        }).toList();
        _calculateTotalAmount();
      });
    }
  }

  Future<void> _setBudget() async {
    if (_budgetController.text.isEmpty) {
      return;
    }
    String budget = _budgetController.text;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budget')
          .doc('weeklyBudget')
          .set({'amount': budget});
      setState(() {
        _weeklyBudget = budget;
      });
    }
  }

  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      String category = _categoryController.text;
      double amount = double.parse(_amountController.text);
      String date = _dateController.text;

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        double currentTotal = _totalAmount + amount;
        double weeklyBudget = double.parse(_weeklyBudget);

        print('Current Total: $currentTotal');
        print('Weekly Budget: $weeklyBudget');

        if (currentTotal > weeklyBudget) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Budget Exceeded'),
              content:
                  Text('Adding this expense will exceed your weekly budget.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return; // Stop the function execution
        }

        // Proceed with adding the expense if within budget
        DocumentReference docRef = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('expenses')
            .add({'category': category, 'amount': amount, 'date': date});
        setState(() {
          _expenses.add({
            'id': docRef.id,
            'category': category,
            'amount': amount.toString(),
            'date': date,
          });
          _calculateTotalAmount();
        });

        _categoryController.clear();
        _amountController.clear();
        _dateController.clear();
      }
    }
  }

  Future<void> _editExpense(Map<String, dynamic> expense) async {
    _categoryController.text = expense['category'];
    _amountController.text = expense['amount'];
    _dateController.text = expense['date'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Expense'),
        content: CategoryWidget(
          formKey: _formKey,
          categoryController: _categoryController,
          amountController: _amountController,
          dateController: _dateController,
          onAddExpense: () async {
            if (_formKey.currentState!.validate()) {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('expenses')
                    .doc(expense['id'])
                    .update({
                  'category': _categoryController.text,
                  'amount': double.parse(_amountController.text),
                  'date': _dateController.text,
                });
                _loadData(); // Reload data to reflect changes
                Navigator.of(context).pop();

                // Calculate total expenses after edit
                _calculateTotalAmount();

                // Check if total expenses exceed weekly budget
                if (_totalAmount > double.parse(_weeklyBudget)) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Budget Warning'),
                      content:
                          Text('Your total expenses exceed the weekly budget.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            }
          },
          onSelectDate: _selectDate,
        ),
      ),
    );
  }

  Future<void> _deleteExpense(Map<String, dynamic> expense) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(expense['id'])
          .delete();
      setState(() {
        _expenses.removeWhere((e) => e['id'] == expense['id']);
        _calculateTotalAmount();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _calculateTotalAmount() {
    double total = 0.0;
    for (var expense in _expenses) {
      total += double.parse(expense['amount']);
    }
    setState(() {
      _totalAmount = total;
    });
  }

  Future<void> _confirmLogout() async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(), // Assuming you have a LoginScreen
        ),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete Account'),
        content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  await user.delete();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                } catch (e) {
                  print('Error deleting account: $e');
                  // Handle error
                }
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Perform deletion logic here
      print('Account deletion confirmed');
    }
  }

  void _editBudget(String newBudget) {
    setState(() {
      _weeklyBudget = newBudget;
    });

    double budgetAmount = double.parse(newBudget);
    if (_totalAmount > budgetAmount) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Budget Warning'),
          content: Text('Your total expenses exceed the weekly budget.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    // Update Firebase or any other backend with _weeklyBudget value
    print('Edit Budget: $_weeklyBudget');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 20.0, // Adjust as needed
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDeleteAccount,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    BudgetWidget(
                      budgetController: _budgetController,
                      weeklyBudget: _weeklyBudget,
                      onSetBudget: _setBudget,
                      onEditBudget: _editBudget,
                      onDeleteBudget: () {
                        // Implement delete if needed
                      },
                    ),
                    SizedBox(height: 20),
                    CategoryWidget(
                      formKey: _formKey,
                      categoryController: _categoryController,
                      amountController: _amountController,
                      dateController: _dateController,
                      onAddExpense: _addExpense,
                      onSelectDate: _selectDate,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _addExpense,
                          child: Text('Add Expense'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ExpensesTable(
                                  expenses: _expenses,
                                  totalAmount: _totalAmount,
                                  onDelete: _deleteExpense,
                                  onEdit: _editExpense,
                                ),
                              ),
                            );
                          },
                          child: Text('Show Expense Table'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HistoryPage(),
                              ),
                            );
                          },
                          child: Text('History'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
