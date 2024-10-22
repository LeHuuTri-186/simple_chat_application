abstract class AiModel {
  Future<String> sendRequest(List<Map<String, String>> messages, {List<String>? stop});
}