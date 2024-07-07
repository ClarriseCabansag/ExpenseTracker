import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BudgetWidget extends StatefulWidget {
  final TextEditingController budgetController;
  final String weeklyBudget;
  final VoidCallback onSetBudget;
  final ValueChanged<String> onEditBudget;
  final VoidCallback onDeleteBudget;

  BudgetWidget({
    required this.budgetController,
    required this.weeklyBudget,
    required this.onSetBudget,
    required this.onEditBudget,
    required this.onDeleteBudget,
  });

  @override
  _BudgetWidgetState createState() => _BudgetWidgetState();
}

class _BudgetWidgetState extends State<BudgetWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: TextFormField(
                controller: widget.budgetController,
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
              onPressed: () {
                widget.onEditBudget(widget.budgetController.text);
              },
              child: Text('Set Budget'),
            ),
          ],
        ),
        SizedBox(height: 10),
        widget.weeklyBudget.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Weekly Budget: ${widget.weeklyBudget}',
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
