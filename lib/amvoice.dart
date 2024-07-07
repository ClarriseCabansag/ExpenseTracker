import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AmVoiceWidget extends StatefulWidget {
  final Function(String) onSpeechResult;

  const AmVoiceWidget({Key? key, required this.onSpeechResult}) : super(key: key);

  @override
  _AmVoiceWidgetState createState() => _AmVoiceWidgetState();

  void startListening() {}
}

class _AmVoiceWidgetState extends State<AmVoiceWidget> {
  final SpeechToText _speechToText = SpeechToText();

  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
    if (_isNumeric(_wordsSpoken)) {
      widget.onSpeechResult(_wordsSpoken); // Pass numeric result to parent widget
    }
  }

  bool _isNumeric(String? str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        Text(
          _wordsSpoken,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
        ),
        SizedBox(height: 16),
        if (_speechToText.isNotListening && _confidenceLevel > 0)
          Text(
            "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w200),
          ),
        SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _speechToText.isListening ? _stopListening : _startListening,
          tooltip: 'Listen',
          child: Icon(
            _speechToText.isNotListening ? Icons.mic : Icons.mic_off,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
      ],
    );
  }
}
