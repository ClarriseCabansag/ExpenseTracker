import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;
  late List<Map<String, dynamic>> _budgetHistory = [];
  late List<Map<String, dynamic>> _expenseHistory = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Load budget history
    QuerySnapshot budgetSnapshot = await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('budget_history')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      _budgetHistory = budgetSnapshot.docs.map((doc) {
        return {
          'amount': doc.get('amount'),
          'timestamp': doc.get('timestamp'),
        };
      }).toList();
    });

    // Load expense history
    QuerySnapshot expenseSnapshot = await _firestore
        .collection('users')
        .doc(_user.uid)
        .collection('expense_history')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      _expenseHistory = expenseSnapshot.docs.map((doc) {
        return {
          'category': doc.get('category'),
          'amount': doc.get('amount'),
          'date': doc.get('date'),
          'timestamp': doc.get('timestamp'),
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildBudgetHistory(),
              SizedBox(height: 20),
              Text(
                'Expense History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildExpenseHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetHistory() {
    return _budgetHistory.isEmpty
        ? Center(child: Text('No budget history available'))
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _budgetHistory.length,
            itemBuilder: (context, index) {
              var budget = _budgetHistory[index];
              return ListTile(
                title: Text('Amount: ${budget['amount']}'),
                subtitle: Text('Set on: ${budget['timestamp'].toDate()}'),
              );
            },
          );
  }

  Widget _buildExpenseHistory() {
    return _expenseHistory.isEmpty
        ? Center(child: Text('No expense history available'))
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _expenseHistory.length,
            itemBuilder: (context, index) {
              var expense = _expenseHistory[index];
              return ListTile(
                title: Text('Category: ${expense['category']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount: ${expense['amount']}'),
                    Text('Date: ${expense['date']}'),
                  ],
                ),
              );
            },
          );
  }
}
