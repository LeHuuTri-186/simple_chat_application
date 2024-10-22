import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:llm_demo/model/llama/LlamaModel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final llamaModel = LlamaModel(apiUrl: "http://localhost:3000/v1/chat/completions", apiKey: "");
  
  final ChatUser _currentUser = ChatUser(id: '1',
          firstName: 'Huu Tri',
          lastName: 'Le');

  final ChatUser _gptUser = ChatUser(
    id: '2',
    firstName: 'Llama',
  );

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUser = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
        title: const Text.rich(
            style: TextStyle(color: Colors.white),
            TextSpan(
                text: "STEP",
                style: TextStyle(fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                      text: "AI",
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 30))
                ])),
      ),
      body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUser,
          messageListOptions:
            MessageListOptions(
              scrollPhysics: ScrollPhysics(),
              scrollController: ScrollController()
            ),
          messageOptions:
              const MessageOptions(
                textColor: Colors.white,
                currentUserContainerColor: Colors.black54,
                containerColor: Colors.black54,
                currentUserTextColor: Colors.white,
              ),
          onSend: (m) {
            getChatResponse(m);
          },
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUser.add(_gptUser);
    });

    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      }

      return Messages(role: Role.assistant, content: m.text);
    }).toList();

    final List<Map<String, String>> messageHistory = _messages.reversed.map((msg) {
      return {
        "role": msg.user == _currentUser ? 'user' : 'assistant',
        "content": msg.text,
      };
    }).toList();

    String messageHistoryString = _messagesHistory.where((m) => m.role == Role.user).map((m) => m.content.toString()).join(". ");

    try {
      final response = await llamaModel.sendRequest(messageHistory);

      setState(() {
        _messages.insert(0,
            ChatMessage(
              user: _gptUser,
              createdAt: DateTime.now(),
              text: response.toString(),
              isMarkdown: true,
            ));
      });
    } catch(e) {
      print("error: $e");
    } finally {
      setState(() {
        _typingUser.removeAt(0);
      });
    }
  }
}