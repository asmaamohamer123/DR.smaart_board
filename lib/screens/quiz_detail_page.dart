import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizDetailsPage extends StatefulWidget {
  final String subjectName;
  final String quizId;
  final Map<String, dynamic> quizData;

  const QuizDetailsPage({
    super.key,
    required this.subjectName,
    required this.quizId,
    required this.quizData,
  });

  @override
  _QuizDetailsPageState createState() => _QuizDetailsPageState();
}

class _QuizDetailsPageState extends State<QuizDetailsPage> {
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = List<Map<String, dynamic>>.from(widget.quizData['questions']);
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectName)
          .collection('quizzes')
          .doc(widget.quizId)
          .update({
        'questions': _questions,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حفظ التعديلات: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الكويز'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> question = _questions[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السؤال ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteQuestion(index),
                      ),
                    ],
                  ),
                  TextField(
                    onChanged: (value) {
                      question['question'] = value;
                    },
                    controller: TextEditingController(text: question['question']),
                    decoration: const InputDecoration(
                      labelText: 'نص السؤال',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (question['type'] == 'multiple_choice')
                    ...List.generate(4, (optionIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: TextField(
                            onChanged: (value) {
                              question['options'][optionIndex] = value;
                            },
                            controller: TextEditingController(
                                text: question['options'][optionIndex]),
                            decoration: InputDecoration(
                              labelText: 'الخيار ${optionIndex + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          leading: Radio<String>(
                            value: question['options'][optionIndex],
                            groupValue: question['correctAnswer'],
                            onChanged: (value) {
                              setState(() {
                                question['correctAnswer'] = value;
                              });
                            },
                          ),
                        ),
                      );
                    })
                  else if (question['type'] == 'true_false')
                    ...List.generate(2, (optionIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RadioListTile<String>(
                          title: Text(question['options'][optionIndex]),
                          value: question['options'][optionIndex],
                          groupValue: question['correctAnswer'],
                          onChanged: (value) {
                            setState(() {
                              question['correctAnswer'] = value;
                            });
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
