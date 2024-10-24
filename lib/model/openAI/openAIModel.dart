import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIModel {
  final String apiKey;

  final String url = "https://api.openai.com/v1/chat/completions";
  OpenAIModel({
    required this.apiKey,
  });
  Future<String> callOpenAI(List<Map<String, String>> messages) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": messages
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String apiResponse = data['choices'][0]['message']['content'];
      return apiResponse;
    } else {
      return "Error: ${response.statusCode}";
    }
  }
}
