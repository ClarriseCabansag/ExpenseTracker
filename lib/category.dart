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

  Future<void> _showVoiceRecognitionDialog(
      BuildContext context, Widget dialogContent) async {
    await showDialog(
      context: context,
      barrierDismissible:
          true, // Allow dismissing the dialog by tapping outside
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // No background color
        elevation: 0, // No elevation
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
              fillColor: Color.fromARGB(255, 27, 27, 27).withOpacity(0.05),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black.withOpacity(0.05), width: 0.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.mic),
                onPressed: () async {
                  await _showVoiceRecognitionDialog(
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
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}$')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Amount (₱)',
                    filled: true,
                    fillColor:
                        Color.fromARGB(255, 17, 17, 17).withOpacity(0.05),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.05), width: 0.5),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () async {
                        await _showVoiceRecognitionDialog(
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
                    fillColor:
                        Color.fromARGB(255, 26, 25, 25).withOpacity(0.01),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.05), width: 0.5),
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
        ],
      ),
    );
  }
}
