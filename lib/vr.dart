import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoiceRecognitionWidget extends StatefulWidget {
  final Function(String) onSpeechResult;

  const VoiceRecognitionWidget(
      {Key? key,
      required this.onSpeechResult,
      required Null Function(String recognizedSpeech) onResult})
      : super(key: key);

  @override
  _VoiceRecognitionWidgetState createState() => _VoiceRecognitionWidgetState();
}

class _VoiceRecognitionWidgetState extends State<VoiceRecognitionWidget> {
  final SpeechToText _speechToText = SpeechToText();

  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  String uid = "";

  @override
  void initState() {
    super.initState();
    _getUserUid();
    initSpeech();
  }

  void _getUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  void initSpeech() async {
    await _speechToText.initialize(
      onError: (error) => print('Error: $error'),
    );
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

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
    widget.onSpeechResult(
        _wordsSpoken); // Pass the recognized speech to parent widget
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
        if (!_speechToText.isListening && _confidenceLevel > 0)
          Text(
            "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200),
          ),
        SizedBox(height: 16),
        FloatingActionButton(
          onPressed:
              _speechToText.isListening ? _stopListening : _startListening,
          tooltip: 'Listen',
          child: Icon(
            _speechToText.isListening ? Icons.mic : Icons.mic_off,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
      ],
    );
  }
}
