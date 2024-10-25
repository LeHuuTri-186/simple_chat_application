import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:llm_demo/model/AiModel.dart';

class LlamaModel implements AiModel {
  final String apiUrl;
  final String apiKey;
  final String model;
  final int maxTokens;
  final bool stream;
  final double temperature;
  final double topP;
  final double frequencyPenalty;

  LlamaModel({
    required this.apiUrl,
    required this.apiKey,
    this.model = "unsloth/Llama-3.2-1B-Instruct-GGUF",
    this.maxTokens = 2048,
    this.stream = false,
    this.temperature = 1.0,
    this.topP = 1.0,
    this.frequencyPenalty = 0.3,
  });

  @override
  Future<String> sendRequest(List<Map<String, String>> messages, {List<String>? stop}) async {

    final recentHistory = messages.sublist(
      max(0, messages.length - 3),
      messages.length,
    );

    final Map<String, dynamic> payload = {
      "messages": recentHistory,
      "model": model,
      "max_tokens": maxTokens,
      "stop": stop,
      "stream": stream,
      "temperature": temperature,
      "top_p": topP,
      "frequency_penalty": frequencyPenalty,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (stream) {
          return _handleStreamResponse(responseData);
        } else {
          return responseData['choices'][0]['message']['content'];
        }
      } else {
        throw Exception('Failed to get response from LLaMA API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in LLaMA request: $e');
    }
  }

  String _handleStreamResponse(Map<String, dynamic> responseData) {
    return responseData['choices'][0]['delta']['content'] ?? '';
  }
}

