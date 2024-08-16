import 'dart:io';
import 'package:attendance/screens/assignmentpage.dart';
import 'package:attendance/screens/lecturepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance/screens/professor_quiz_creation_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key, required this.title});
  final String title;

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      LecturePage(subjectName: widget.title),
      AssignmentPage(subjectName: widget.title),
      ProfessorQuizCreationPage(subjectName: widget.title),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      String? filePath = result.files.single.path;
      String fileName = result.files.single.name;

      if (filePath != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          Uint8List fileBytes = await File(filePath).readAsBytes();

          Reference storageRef =
              FirebaseStorage.instance.ref().child('uploads/$fileName');
          UploadTask uploadTask = storageRef.putData(fileBytes);

          await uploadTask.whenComplete(() async {
            String downloadURL = await storageRef.getDownloadURL();

            String subCollectionName =
                _selectedIndex == 0 ? 'lectures' : 'assignments';
            String subjectName = widget.title;

            await FirebaseFirestore.instance
                .collection('subjects')
                .doc(subjectName)
                .collection(subCollectionName)
                .add({
              'file_name': fileName,
              'file_url': downloadURL,
              'created_at': Timestamp.now(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع الملف بنجاح')),
            );
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في رفع الملف: $e')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحديد الملف')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Expanded(
              child: _pages[_selectedIndex],
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.school,
              color: Colors.white,
            ),
            label: 'المحاضرات',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment,
              color: Colors.white,
            ),
            label: 'التاسكات',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.quiz,
              color: Colors.white,
            ),
            label: 'الكويزات',
          ),
        ],
        selectedFontSize: 20,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex < 2
          ? FloatingActionButton.extended(
              onPressed: _pickAndUploadFile,
              label: Text(_selectedIndex == 0 ? 'إضافة محاضرة' : 'إضافة تاسك'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}
