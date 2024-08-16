import 'package:attendance/screens/quiz_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QuizListPage extends StatefulWidget {
  final String subjectName;

  const QuizListPage({super.key, required this.subjectName});

  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes for: ${widget.subjectName}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subjects')
            .doc(widget.subjectName)
            .collection('quizzes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching quizzes'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No quizzes available.'));
          } else {
            return Stack(
              children: [
                ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    DocumentSnapshot quizDoc = snapshot.data!.docs[index];
                    Map<String, dynamic> quizData =
                        quizDoc.data()! as Map<String, dynamic>;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          quizData['quizTitle'] ?? 'Quiz Title',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _generatePDF(quizDoc.id, quizData['quizTitle']);
                              },
                              child: const Text('عرض الدرجات'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizDetailsPage(
                                      subjectName: widget.subjectName,
                                      quizId: quizDoc.id,
                                      quizData: quizData,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool confirmDelete =
                                    await _confirmDelete(context);
                                if (confirmDelete) {
                                  await _deleteQuiz(quizDoc.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_isDeleting)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteQuiz(String quizId) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectName)
          .collection('quizzes')
          .doc(quizId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete quiz: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this quiz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _generatePDF(String quizId, String quizTitle) async {
    final pdf = pw.Document();
    final results = await FirebaseFirestore.instance
        .collection('results')
        .where('quizId', isEqualTo: quizId)
        .get();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Quiz: $quizTitle',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Name', 'Email', 'Score', 'Time'],
                data: results.docs.map((doc) {
                  return [
                    doc['name'],
                    doc['email'],
                    '${doc['score']}/${doc['totalQuestions']}',
                    doc['timestamp'].toDate().toString().substring(0, 16), // Date and time without seconds
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
