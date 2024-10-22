import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:llm_demo/model/AiModel.dart';


class GeminiChatModel implements AiModel {
  final String apiKey;
  final String baseURl;

  GeminiChatModel({required this.apiKey, required this.baseURl});

  @override
  Future<String> sendRequest(List<Map<String, String>> messages, {List<String>? stop}) async {
    final recentHistory = messages.sublist(
      max(0, messages.length - 5),
      messages.length,
    );

    final String historyString = recentHistory.map((msg) {
      return "${msg['role']}: ${msg['content']}";
    }).join('\n');

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final response = await model.generateContent([Content.text(historyString)]);
    print(response.text);
    final answer = response.text;
    return answer.toString();
  }
}