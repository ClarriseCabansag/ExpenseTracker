// Weekly.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class WeeklyBudgetWidget extends StatefulWidget {
  final Function onBudgetSet;

  WeeklyBudgetWidget({required this.onBudgetSet});

  @override
  _WeeklyBudgetWidgetState createState() => _WeeklyBudgetWidgetState();
}

class _WeeklyBudgetWidgetState extends State<WeeklyBudgetWidget> {
  final _budgetController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _weeklyBudget = '';

  @override
  void initState() {
    super.initState();
    _loadWeeklyBudget();
  }

  Future<void> _loadWeeklyBudget() async {
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
          _weeklyBudget = '₱${budgetDoc['amount']}';
        });
      } else {
        setState(() {
          _weeklyBudget = '';
        });
      }
    }
  }

  void _setBudget() {
    if (_budgetController.text.isNotEmpty) {
      _weeklyBudget = '₱${_budgetController.text}';
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('budget')
            .doc('weeklyBudget')
            .set({
          'amount': _budgetController.text,
        }).then((value) {
          widget.onBudgetSet();
          _loadWeeklyBudget();
        });
      }
      _budgetController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                ],
                decoration: InputDecoration(
                  labelText: 'Weekly Amount (₱)',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter budget amount';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _setBudget,
              child: Text('Set Budget'),
            ),
          ],
        ),
        SizedBox(height: 10),
        _weeklyBudget.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Weekly Budget: $_weeklyBudget',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Container(),
      ],
    );
  }
}
