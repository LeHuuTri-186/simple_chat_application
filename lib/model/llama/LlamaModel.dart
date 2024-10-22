import 'dart:convert';
import 'package:http/http.dart' as http;

class LlamaModel {
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
    this.temperature = 0.7,
    this.topP = 1.0,
    this.frequencyPenalty = 0.0,
  });

  Future<String> sendRequest(List<Map<String, String>> messages, {List<String>? stop}) async {
    final Map<String, dynamic> payload = {
      "messages": messages,
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

