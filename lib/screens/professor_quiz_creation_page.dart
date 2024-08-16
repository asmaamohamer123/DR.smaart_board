import 'package:attendance/screens/quiz_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessorQuizCreationPage extends StatefulWidget {
  final String subjectName;

  const ProfessorQuizCreationPage({super.key, required this.subjectName});

  @override
  _ProfessorQuizCreationPageState createState() =>
      _ProfessorQuizCreationPageState();
}

class _ProfessorQuizCreationPageState extends State<ProfessorQuizCreationPage> {
  final TextEditingController _quizTitleController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    addFieldToSubject(widget.subjectName);
  }

  void _addMultipleChoiceQuestion() {
    setState(() {
      _questions.add({
        'type': 'multiple_choice',
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswer': null,
      });
    });
  }

  void _addTrueFalseQuestion() {
    setState(() {
      _questions.add({
        'type': 'true_false',
        'question': '',
        'options': ['True', 'False'],
        'correctAnswer': null,
      });
    });
  }

  Future<void> _saveQuiz() async {
    if (_quizTitleController.text.isEmpty ||
        _questions.isEmpty ||
        _questions.any((q) =>
            q['question'].isEmpty ||
            (q['options'] as List<String>).any((o) => o.isEmpty) ||
            q['correctAnswer'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'يرجى إدخال اسم الكويز وإكمال جميع الأسئلة والإجابات وتحديد الإجابة الصحيحة')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectName)
          .collection('quizzes')
          .add({
        'quizTitle': _quizTitleController.text,
        'questions': _questions,
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الكويز بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حفظ الكويز: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void addFieldToSubject(String subjectName) async {
    final firestore = FirebaseFirestore.instance;
    final subjectDocRef = firestore.collection('subjects').doc(subjectName);

    // إضافة الحقل إلى المستند إذا لم يكن موجودًا
    await subjectDocRef.set({'customField': 'defaultValue'}, SetOptions(merge: true));
  }

  void _navigateToQuizList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizListPage(subjectName: widget.subjectName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _quizTitleController,
                      decoration: InputDecoration(
                        labelText: 'اسم الكويز',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _questions[index]['type'] ==
                                              'multiple_choice'
                                          ? ':سؤال اختياري'
                                          : ':سؤال صح أو خطأ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteQuestion(index),
                                    ),
                                  ],
                                ),
                                TextField(
                                  onChanged: (value) {
                                    _questions[index]['question'] = value;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'أدخل السؤال',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_questions[index]['type'] ==
                                    'multiple_choice')
                                  ...List.generate(4, (optionIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: ListTile(
                                        title: TextField(
                                          onChanged: (value) {
                                            _questions[index]['options']
                                                [optionIndex] = value;
                                          },
                                          decoration: InputDecoration(
                                            labelText:
                                                'الخيار ${optionIndex + 1}',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        leading: Radio<String>(
                                          value: _questions[index]['options']
                                              [optionIndex],
                                          groupValue: _questions[index]
                                              ['correctAnswer'],
                                          onChanged: (value) {
                                            setState(() {
                                              _questions[index]
                                                  ['correctAnswer'] = value;
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  })
                                else if (_questions[index]['type'] ==
                                    'true_false')
                                  ...List.generate(2, (optionIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: RadioListTile<String>(
                                        title: Text(_questions[index]['options']
                                            [optionIndex]),
                                        value: _questions[index]['options']
                                            [optionIndex],
                                        groupValue: _questions[index]
                                            ['correctAnswer'],
                                        onChanged: (value) {
                                          setState(() {
                                            _questions[index]['correctAnswer'] =
                                                value;
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _addMultipleChoiceQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('سؤال اختياري'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addTrueFalseQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text('سؤال صح أو خطأ'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveQuiz,
                          icon: const Icon(Icons.save),
                          label: const Text('حفظ الكويز'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _navigateToQuizList,
                          icon: const Icon(Icons.list),
                          label: const Text('عرض الكويزات'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
