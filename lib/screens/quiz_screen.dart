import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  bool _isError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      
      final questions = await ApiService.fetchQuestions();
      
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _checkAnswer(String selectedAnswer) {
    if (_hasAnswered) return;
    
    final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
    final isCorrect = selectedAnswer == correctAnswer;
    
    setState(() {
      _hasAnswered = true;
      _selectedAnswer = selectedAnswer;
      
      if (isCorrect) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedAnswer = "";
        _feedbackText = "";
      } else {
        _currentQuestionIndex = _questions.length;  // Force display of results
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _hasAnswered = false;
      _selectedAnswer = "";
      _feedbackText = "";
      _isLoading = true;
    });
    _loadQuestions();
  }

  Color _getOptionColor(String option) {
    if (!_hasAnswered) return Colors.blue;
    
    final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
    
    if (option == correctAnswer) {
      return Colors.green;
    } else if (option == _selectedAnswer) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Act 15 - Trivia Quiz App'),
        backgroundColor: Colors.blue,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading questions: $_errorMessage', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_questions.isEmpty) {
      return const Center(child: Text('No questions available.'));
    }
    
    if (_currentQuestionIndex >= _questions.length) {
      return _buildQuizComplete();
    }
    
    return _buildQuizQuestion();
  }

  Widget _buildQuizQuestion() {
    final question = _questions[_currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          Text(
            question.question,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          
          ...question.options.map((option) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: _hasAnswered ? null : () => _checkAnswer(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getOptionColor(option),
                disabledBackgroundColor: _getOptionColor(option),
              ),
              child: Text(option),
            ),
          )),
          
          const SizedBox(height: 16),
          
          if (_hasAnswered)
            Text(
              _feedbackText,
              style: TextStyle(
                fontSize: 16,
                color: _selectedAnswer == question.correctAnswer ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          
          const Spacer(),
          
          if (_hasAnswered)
            ElevatedButton(
              onPressed: _nextQuestion,
              child: Text(
                _currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'See Results',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizComplete() {
    final percentage = (_score / _questions.length) * 100;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Quiz Complete!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Score: $_score/${_questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _restartQuiz,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
} 