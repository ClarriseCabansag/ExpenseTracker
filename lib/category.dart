import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'amvoice.dart'; // Ensure this import is correct
import 'vr.dart'; // Import the VoiceRecognitionWidget

class CategoryWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController categoryController;
  final TextEditingController amountController;
  final TextEditingController dateController;
  final VoidCallback onAddExpense;
  final Future<void> Function(BuildContext) onSelectDate;

  CategoryWidget({
    required this.formKey,
    required this.categoryController,
    required this.amountController,
    required this.dateController,
    required this.onAddExpense,
    required this.onSelectDate,
  });

  Future<void> _showDialog(BuildContext context, Widget dialogContent) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: dialogContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: categoryController,
            decoration: InputDecoration(
              labelText: 'Category',
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.mic),
                onPressed: () async {
                  await _showDialog(
                    context,
                    VoiceRecognitionWidget(
                      onSpeechResult: (result) {
                        categoryController.text = result;
                        if (Navigator.of(context).canPop()) {
                          Navigator.pop(context);
                        }
                      },
                      onResult: (String recognizedSpeech) {},
                    ),
                  );
                },
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter category';
              }
              return null;
            },
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Amount (₱)',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () async {
                        await _showDialog(
                          context,
                          AmVoiceWidget(
                            onSpeechResult: (result) {
                              amountController.text = result;
                              if (Navigator.of(context).canPop()) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter amount';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date (YYYY-MM-DD)',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.01),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => onSelectDate(context),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter date';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: onAddExpense,
            child: Text('Add Expense'),
          ),
        ],
      ),
    );
  }
}
