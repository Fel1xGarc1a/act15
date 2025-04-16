import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions({
    int amount = 10,
    int category = 9,
    String difficulty = 'easy',
    String type = 'multiple',
  }) async {
    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=$type',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['response_code'] == 0) {
        return (data['results'] as List)
            .map((questionData) => Question.fromJson(questionData))
            .toList();
      } else {
        throw Exception('API error');
      }
    } else {
      throw Exception('Failed to load questions');
    }
  }
} 