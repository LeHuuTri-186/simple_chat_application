import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:llm_demo/model/gemini/GeminiModel.dart';
import 'package:llm_demo/model/llama/LlamaModel.dart';
import 'package:llm_demo/presentation/widget/collapsible_row_tool.dart';
import 'package:llm_demo/presentation/widget/drop_down_widget.dart';
import 'package:llm_demo/presentation/widget/prompt_drop_down_widget.dart';
import 'package:llm_demo/utils/api_key.dart';

import '../../model/AiModel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String currentModel = "Llama 3.2";
  AiModel geminiModel = GeminiChatModel(
      apiKey: GEMINI_API_KEY,
      baseURl: "https://gemini.googleapis.com/v1/chat:sendMessage");

  AiModel llamaModel = LlamaModel(
      apiUrl: "http://localhost:3000/v1/chat/completions", apiKey: "na");
  late ChatUser _currentUser;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = ChatUser(id: '1', firstName: 'Huu Tri', lastName: 'Le');
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  final ChatUser _llamaUser = ChatUser(
      id: '2',
      firstName: 'Llama 3.2',
      profileImage: './core/assets/model_logo/llama-3_2.png');

  final ChatUser _geminiUser = ChatUser(
      id: '3',
      firstName: 'Gemini Flash',
      profileImage: 'lib/core/assets/model_logo/gemini-flash.png');

  final List<ChatMessage> _messages = <ChatMessage>[];
  final List<ChatUser> _typingUser = <ChatUser>[];

  final List<Map<String, String>> aiModels = [
    {
      'name': 'Gemini 1.5 Flash',
      'logo': 'lib/core/assets/model_logo/gemini-flash.png'
    },
    {'name': 'Llama 3.2', 'logo': 'lib/core/assets/model_logo/llama-3_2.png'},
  ];

  final List<Map<String, String>> promptModels = [
    {
      'name': 'Hello world',
      'prompt': 'Write a hello world program in [] language'
    },
    {
      'name': 'Email',
      'prompt': 'Write a sample [] Email'
    },
    {
      'name': 'Explain',
      'prompt': 'Explain to me []'
    },
    {
      'name': 'Idea',
      'prompt': 'Give me an idea on []'
    },
  ];

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
        inputOptions: InputOptions(
          inputMaxLines: 4,
          textController: textEditingController,
          sendOnEnter: true,
          leading: <Widget>[
            Row(
              children: [
                DropdownWidget(
                    aiModels: aiModels,
                    onChange: (model) {
                      setState(() {
                        currentModel = model ?? "Llama 3.2";
                      });
                    }),
                CollapsibleRowTool(
                  widgets: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PromptDropdownWidget(aiModels: promptModels, onChange: (prompt) {
                        setState(() {
                          textEditingController.value = textEditingController.value.copyWith(
                            text: prompt
                          );
                          textEditingController.selection = TextSelection.collapsed(offset: prompt!.indexOf('[]') + 1);;
                        });
                      }),
                    ),
                    IconButton(
                      onPressed: () => {

                      },
                      icon: const Icon(Icons.file_upload),
                      tooltip: "Upload files",
                    ),
                    IconButton(
                      onPressed: () => {
                        setState(() {
                          _messages.clear();
                        })
                      },
                      icon: const Icon(Icons.history),
                      tooltip: "Clear history",
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        typingUsers: _typingUser,
        scrollToBottomOptions: const ScrollToBottomOptions(),
        messageListOptions: MessageListOptions(
            scrollPhysics: const ScrollPhysics(),
            scrollController: ScrollController()),
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.blueAccent,
          textColor: Colors.white,
          avatarBuilder: (chatUser, func1, func2) => Center(
            child: Container(
                margin: const EdgeInsets.all(3.0),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: chatUser.firstName == "Llama 3.2"
                      ? Image.asset(
                          'lib/core/assets/model_logo/llama-3_2.png',
                          height: 32,
                          width: 32,
                        )
                      : Image.asset(
                          'lib/core/assets/model_logo/gemini-flash.png',
                          height: 32,
                          width: 32,
                        ),
                )),
          ),
        ),
        onSend: (m) {
          getChatResponse(m);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUser.add(currentModel == "Llama 3.2" ? _llamaUser : _geminiUser);
    });

    final List<Map<String, String>> messageHistory =
      _messages.reversed.map((msg) {
      return {
        "role": msg.user == _currentUser ? 'user' : 'assistant',
        "content": msg.text,
      };
    }).toList();

    try {
      AiModel model = currentModel == "Llama 3.2" ? llamaModel : geminiModel;

      final response = await model.sendRequest(messageHistory);

      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              user: currentModel == "Llama 3.2" ? _llamaUser : _geminiUser,
              createdAt: DateTime.now(),
              text: response.toString(),
              isMarkdown: true,
            ));
      });
    } catch (e) {
      print("error: $e");
    } finally {
      setState(() {
        _typingUser.removeAt(0);
      });
    }
  }
}
