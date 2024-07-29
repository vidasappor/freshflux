import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

  Future<String> fetchAIInfo(String productCategory, String productName) async {
     const String tear = 'https://api.openai.com/v1/chat/completions';

    // Construct the prompt for the AI
     const String samp = '';
    final String prompt = '''
You are an advanced AI trained to provide detailed information about different products. Consider the following product details:
Category: "$productCategory"
Product Name: "$productName"
Based on your training and the provided information, offer relevant information about this product. If it is a medicine, describe the diseases it can treat. If it is a dairy or canned product, provide some recipes that can be made with it. Use your expertise to provide an accurate and complete description within a maximum of 200 tokens.
''';

    // Payload to send in the request
    final Map<String, dynamic> payload = {
      'model': 'gpt-4',
      'max_tokens': 200,
      'temperature': 0.0, // Set to 0 for deterministic output
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
    };

    // Headers for the request
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $samp',
    };

    // Estimate token usage: Add input and output tokens (assuming response token count is around 50)
    final estimatedTokens = prompt.length ~/ 4 + 50;

    int retryCount = 0;
    const int maxRetries = 3;
    const Duration initialDelay = Duration(seconds: 5);

    while (retryCount < maxRetries) {
      try {
        // Send the HTTP POST request
        final response = await http.post(
          Uri.parse(tear),
          headers: headers,
          body: json.encode(payload),
        );

        // If the request is successful, parse and return the AI response
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final String completion = _extractResponseContent(jsonResponse);
          return completion;
        } else {
          // Handle non-200 response codes
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          if (errorResponse['error']['code'] == 'rate_limit_exceeded') {
            throw RateLimitExceededException(errorResponse['error']['message']);
          } else {
            throw Exception('Failed to get response from API: ${response.body}');
          }
        }
      } catch (error) {
        // Handle rate limit exceptions with retry logic
        if (error is RateLimitExceededException) {
          retryCount++;
          final delay = initialDelay * retryCount;
          await Future.delayed(delay);
        } else {
          print('Error: $error');
          throw error;
        }
      }
    }

    // Throw an exception if maximum retries are reached
    throw Exception('Failed to get response from API after $maxRetries retries');
  }

  // Extract the AI response content
  String _extractResponseContent(Map<String, dynamic> response) {
    final String messageContent = response['choices'][0]['message']['content'] as String;
    return messageContent.trim();
  }


class RateLimitExceededException implements Exception {
  final String message;

  RateLimitExceededException(this.message);

  @override
  String toString() => 'RateLimitExceededException: $message';
}
