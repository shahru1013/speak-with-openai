import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:talk_to_me/constants/constants.dart';
import 'package:talk_to_me/providers/chats_provider.dart';
import 'package:talk_to_me/screens/speech_screen_widget.dart';
import 'package:talk_to_me/widgets/chat_widget.dart';
import 'package:talk_to_me/widgets/drawer_widget.dart';

import '../providers/models_provider.dart';
import '../services/assets_manager.dart';
import '../widgets/text_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  bool _isAnimationStart = false;
  bool shouldAnimate = true;
  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  _textAnimationCallback(bool isFinished) {
    setState(() {
      _isAnimationStart = isFinished;
      shouldAnimate = false;
    });
  }

  // List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerWidget(),
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          color: Colors.white,
        ),
        title: Container(
            child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                // height: 50,
                padding: EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(AssetsManager.openaiLogo),
                ),
              ),
              const Text("ChatGPT"),
            ],
          ),
        )),
        actions: [
          SizedBox(
            // width: 30,
            child: PopupMenuButton(
              offset: Offset(-5, 0),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              onSelected: (value) {
                if (value == 'clear') {
                  chatProvider.clearChats();
                  setState(() {
                    _isAnimationStart = false;
                  });
                }
              },
              position: PopupMenuPosition.under,
              child: Container(
                margin: EdgeInsets.only(right: 5),
                child: Icon(Icons.more_horiz),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                PopupMenuItem<String>(
                  // padding: EdgeInsets.fromLTRB(14, 10, 20, 10),
                  height: 24,
                  value: 'clear',
                  child: Text('Clear'),
                ),
                // const PopupMenuDivider(height: 1),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatProvider.getChatList.length, //chatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider.getChatList[index].msg, // chatList[index].msg,
                      chatIndex: chatProvider.getChatList[index].chatIndex, //chatList[index].chatIndex,
                      shouldAnimate: chatProvider.getChatList.length - 1 == index,
                      size: chatProvider.getChatList.length,
                      currentIndex: index,
                      // animationCallback: _textAnimationCallback,
                    );
                  }),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        // color: Colors.amberAccent,
                        child: TextField(
                          // maxLines: 3,
                          textInputAction: TextInputAction.newline,
                          maxLines: null,
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.white),
                          controller: textEditingController,
                          onSubmitted: (value) async {
                            // await sendMessageFCT(modelsProvider: modelsProvider, chatProvider: chatProvider);
                          },
                          decoration: const InputDecoration.collapsed(hintText: "Write or speak something!", hintStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    Container(
                      child: SpeechScreenWidget(
                          textEditingController: textEditingController,
                          finishedCallback: () async {
                            Future.delayed(Duration(milliseconds: 300), () async {
                              await sendMessageFCT(modelsProvider: modelsProvider, chatProvider: chatProvider);
                              textEditingController.clear();
                            });
                          }),
                    ),
                    Container(
                      child: Transform.rotate(
                        angle: -0.7854,
                        child: IconButton(
                          onPressed: () async {
                            await sendMessageFCT(modelsProvider: modelsProvider, chatProvider: chatProvider);
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
      _listScrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
    );
  }

  Future<void> sendMessageFCT({required ModelsProvider modelsProvider, required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You cant send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isAnimationStart = true;
      shouldAnimate = true;
    });
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(msg: msg, chosenModelId: modelsProvider.getCurrentModel);
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }
}
