import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:talk_to_me/constants/api_consts.dart';
import 'package:talk_to_me/services/assets_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  TextEditingController _keyInputController = TextEditingController();
  bool _isAddOpenKeyEnabled = false;
  bool _isLoading = false;

  _doGetAPiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _keyInputController.text = prefs.getString('API_KEY')!;
  }

  /**
     * Show dialog message
     * onSuccess or onError
     */

  _showDialog(String message, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _doAddAPIKey() async {
    if (_keyInputController.text.length > 0) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoading = true;
      });
      /**
         * Check wheather the API key is valid or not!
         * Before save
         */
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer ${_keyInputController.text}'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        _showDialog(jsonResponse['error']["message"], 'Error');
        throw HttpException(jsonResponse['error']["message"]);
      } else {
        prefs.setString('API_KEY', _keyInputController.text);
        setState(() {
          _isAddOpenKeyEnabled = !_isAddOpenKeyEnabled;
        });
        _showDialog('API key added successfully!', 'Success');
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      _showDialog('API key field is empty!', 'Required');
    }
  }

  initState() {
    super.initState();
    _doGetAPiKey();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: kToolbarHeight + 30),
      width: 250,
      child: Drawer(
          backgroundColor: const Color(0xFF444654),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                children: [
                  _isLoading ? const Center(child: CircularProgressIndicator()) : SizedBox(),
                  Column(
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.3)),
                        accountName: Text(
                          'ChatGPT',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 17, 233, 136),
                          ),
                        ),
                        accountEmail: Text(
                          'gpt-3.5-turbo-0301',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 232, 237, 235),
                          ),
                        ),
                        currentAccountPicture: Container(
                          width: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(AssetsManager.openaiLogo),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Container(
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.add,
                                        color: Color.fromARGB(255, 240, 240, 243),
                                        size: 16,
                                      ),
                                    ),
                                    Text(
                                      'Add OpenAI API key',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 240, 240, 243),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _isAddOpenKeyEnabled = !_isAddOpenKeyEnabled;
                          });
                        },
                      ),
                      _isAddOpenKeyEnabled
                          ? Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 5),
                                  color: Color.fromARGB(239, 255, 253, 253),
                                  width: 220,
                                  child: TextFormField(
                                    maxLines: null,
                                    controller: _keyInputController,
                                    decoration: InputDecoration(
                                      hintText: 'OpenAI API Key',
                                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 220,
                                  margin: EdgeInsets.only(top: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            setState(
                                              () {
                                                _isAddOpenKeyEnabled = !_isAddOpenKeyEnabled;
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'Cancel',
                                              style: const TextStyle(
                                                color: Color.fromARGB(255, 230, 61, 61),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 17,
                                              ),
                                            ),
                                          )),
                                      GestureDetector(
                                          onTap: () {
                                            _doAddAPIKey();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            margin: EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'Add',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 17,
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      ListTile(
                        title: Container(
                          child: Row(
                            children: [
                              GestureDetector(
                                  child: Container(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.help,
                                        color: Color.fromARGB(255, 240, 240, 243),
                                        size: 16,
                                      ),
                                    ),
                                    Text(
                                      'How to get OpenAI API key?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 240, 240, 243),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                        onTap: () async {
                          // String url = 'help.openai.com/en/articles/4936850-where-do-i-find-my-secret-api-key';
                          final Uri _url = Uri.parse('https://help.openai.com/en/articles/4936850-where-do-i-find-my-secret-api-key');
                          if (!await launchUrl(_url)) {
                            throw Exception('Could not launch $_url');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          )),
    );
  }
}
