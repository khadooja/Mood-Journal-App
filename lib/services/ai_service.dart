import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Communicates with the OpenAI Chat Completions API to analyse journal text.
///
/// Architecture position:  UI → Cubit → AiService → OpenAI API
///
/// Replace [_apiKey] with your real key before running.
/// In production, load this from a secure env variable / secrets manager —
/// never hard-code a real key in source control.
class AiService {
  /// 🔑 Replace with your OpenAI API key.
  static String get apiKey =>
  
      dotenv.env['OPENAI_API_KEY'] ?? '';
      
      

  static const String _endpoint =
    'https://api.openai.com/v1/responses';

  static const String _systemPrompt = '''
You are an emotionally intelligent mood analyzer for a journaling app.

Analyze the journal entry text and return ONLY valid JSON in this exact format:
{
  "moodIndex": <integer 0-4>,
  "label": "<Rough|Low|Okay|Good|Great>",
  "confidence": <float 0.0-1.0>,
  "insight": "<one concise, empathetic sentence>"
}

Mood scale:
0 = Rough  — very negative (grief, despair, severe stress)
1 = Low    — slightly negative (tired, unmotivated, sad)
2 = Okay   — neutral or mixed feelings
3 = Good   — positive (calm, productive, content)
4 = Great  — very positive (happy, excited, grateful)

Rules:
- Return ONLY the JSON object. No extra text, no markdown, no explanation.
- insight must be a single sentence, max 15 words.
- Do NOT give medical advice.
- Be empathetic but concise.
''';

  /// Sends [text] to OpenAI and returns a structured mood analysis map.
  ///
  /// Returns a [Map] with keys: moodIndex, label, confidence, insight.
  /// Throws [AiServiceException] on network or API errors.
  Future<Map<String, dynamic>> analyzeMood(String text) async {
    final http.Response response;

    try {
      response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
  'model': 'gpt-4o-mini',
  'input': [
    {
      'role': 'system',
      'content': _systemPrompt,
    },
    {
      'role': 'user',
      'content': text,
    }
  ],
  'temperature': 0.3,
  'max_output_tokens': 150,
}),
      );
    } catch (e) {
      throw AiServiceException('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw AiServiceException(
        'OpenAI API returned ${response.statusCode}: ${response.body}',
      );
    }

    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Adjust this parsing logic based on the actual API response structure
      final String content = data['choices'][0]['message']['content'];
      return jsonDecode(content);
    } catch (e) {
      throw AiServiceException('Failed to parse AI response: $e');
    }
  }
}

/// Thrown when [AiService] encounters a network or API error.
class AiServiceException implements Exception {
  final String message;
  const AiServiceException(this.message);

  @override
  String toString() => 'AiServiceException: $message';
}
