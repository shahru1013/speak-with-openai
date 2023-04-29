import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:talk_to_me/constants/constants.dart';
import 'package:talk_to_me/services/assets_manager.dart';

import 'text_widget.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatWidget extends StatefulWidget {
  Function? animationCallback;
  var size;
  var currentIndex;
  ChatWidget({super.key, required this.msg, required this.chatIndex, this.shouldAnimate = false, this.animationCallback, this.size, this.currentIndex});

  final String msg;
  final int chatIndex;
  final bool shouldAnimate;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  FlutterTts flutterTts = FlutterTts();
  bool isTyping = false;
  bool stopTyping = false;

  _startSpeaking() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(widget.msg);
  }

  _stopSpeaking() async {
    await flutterTts.stop();
  }

  @override
  void initState() {
    super.initState();
    if (widget.chatIndex % 2 != 0 && widget.size - 1 == widget.currentIndex) {
      _startSpeaking();
      setState(() {
        isTyping = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: widget.chatIndex == 0 ? scaffoldBackgroundColor : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  widget.chatIndex == 0 ? AssetsManager.userImage : AssetsManager.botImage,
                  height: 30,
                  width: 30,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: widget.chatIndex == 0
                      ? TextWidget(
                          label: widget.msg,
                        )
                      : widget.shouldAnimate && !stopTyping
                          ? DefaultTextStyle(
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                              child: AnimatedTextKit(
                                isRepeatingAnimation: false,
                                repeatForever: false,
                                displayFullTextOnTap: true,
                                totalRepeatCount: 1,
                                animatedTexts: [
                                  TyperAnimatedText(
                                    widget.msg.trim(),
                                  ),
                                ],
                                onFinished: () {
                                  setState(() {
                                    isTyping = false;
                                  });
                                  widget.animationCallback!(false);
                                },
                              ),
                            )
                          : Text(
                              widget.msg.trim(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                ),
                widget.chatIndex == 0
                    ? const SizedBox.shrink()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.thumb_down_alt_outlined,
                            color: Colors.white,
                          )
                        ],
                      ),
              ],
            ),
          ),
        ),
        widget.currentIndex == widget.size - 1 && isTyping
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 100,
                  height: 30,
                  margin: EdgeInsets.only(bottom: 60),
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        stopTyping = true;
                        isTyping = false;
                      });
                      _stopSpeaking();
                    },
                    child: Text(
                      'Stop',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Color.fromRGBO(0, 0, 0, 0.3),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
