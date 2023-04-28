import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

class SpeechScreenWidget extends StatefulWidget {
  TextEditingController textEditingController;
  Function? finishedCallback;
  SpeechScreenWidget({super.key, required this.textEditingController, this.finishedCallback});

  @override
  State<SpeechScreenWidget> createState() => _SpeechScreenWidgetState();
}

class _SpeechScreenWidgetState extends State<SpeechScreenWidget> {
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (status) => print('Onstatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );

      print('available --- ' + available.toString());

      if (available) {
        setState(() {
          isListening = true;
        });

        speech.listen(
          onResult: (result) => setState(() {
            if (result.finalResult) {
              setState(() {
                isListening = false;
              });
              widget.finishedCallback!();
            }
            setState(() {
              widget.textEditingController.text = result.recognizedWords;
            });
          }),
        );
      }
    } else {
      setState(() {
        isListening = false;
      });
      speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.amberAccent,
      height: 50,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: AvatarGlow(
        glowColor: Colors.blue,
        endRadius: 90.0,
        duration: Duration(milliseconds: 1000),
        repeat: true,
        showTwoGlows: true,
        animate: isListening,
        repeatPauseDuration: Duration(milliseconds: 100),
        child: IconButton(
          onPressed: _listen,
          icon: isListening
              ? const Icon(
                  Icons.mic,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.mic_none,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
