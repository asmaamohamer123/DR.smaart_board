import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentPage extends StatelessWidget {
  final String subjectName;

  const AssignmentPage({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
   addFieldToSubject(subjectName);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('subjects')
                  .doc(subjectName)
                  .collection('assignments')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد تاسكات مرفوعة',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                } else {
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return FutureBuilder(
                        future: getFileSize(doc['file_url']),
                        builder:
                            (context, AsyncSnapshot<String> fileSizeSnapshot) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              onTap: () async {
                                showLoadingDialog(context);
                                final url = doc['file_url'];
                                final file =
                                    await downloadPDFFromFirebase(url, context);
                                Navigator.pop(context);
                                if (file != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFViewerPage(
                                        file: file,
                                        title: doc['file_name'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              leading: const Icon(Icons.picture_as_pdf,
                                  color: Colors.redAccent),
                              title: Text(
                                doc['file_name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "تمت الإضافة في: ${formatTimestamp(doc['created_at'])}"),
                                  if (fileSizeSnapshot.hasData)
                                    Text("حجم الملف: ${fileSizeSnapshot.data}"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      showLoadingDialog(context);
                                      final url = doc['file_url'];
                                      try {
                                        await launch(url);
                                      } catch (e) {
                                        print(e);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'لا يمكن فتح الرابط: $e')),
                                        );
                                      } finally {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      bool confirmDelete =
                                          await showDeleteConfirmationDialog(
                                              context);
                                      if (confirmDelete) {
                                        await deleteAssignment(doc, context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  Future<String> getFileSize(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      final metadata = await ref.getMetadata();
      final bytes = metadata.size ?? 0;
      return formatBytes(bytes, 2);
    } catch (e) {
      return "غير متاح";
    }
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes == 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<File?> downloadPDFFromFirebase(
      String url, BuildContext context) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      final bytes = await ref.getData();
      if (bytes != null) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp.pdf');
        await file.writeAsBytes(bytes, flush: true);
        return file;
      }
    } catch (e) {
      print("Error downloading PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء تحميل الملف: $e')),
      );
    }
    return null;
  }

  Future<void> deleteAssignment(
      DocumentSnapshot doc, BuildContext context) async {
    try {
      showLoadingDialog(context);
      final ref = FirebaseStorage.instance.refFromURL(doc['file_url']);
      await ref.delete();

      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectName)
          .collection('assignments')
          .doc(doc.id)
          .delete();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف التاسك بنجاح')),
      );
    } catch (e) {
      Navigator.pop(context);
      print("Error deleting assignment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء حذف التاسك: $e')),
      );
    }
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("تأكيد الحذف"),
              content: const Text("هل أنت متأكد من أنك تريد حذف هذا التاسك؟"),
              actions: <Widget>[
                TextButton(
                  child: const Text("إلغاء"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text("حذف"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
void addFieldToSubject(String subjectName) async {
    final firestore = FirebaseFirestore.instance;
    final subjectDocRef = firestore.collection('subjects').doc(subjectName);

    // إضافة الحقل إلى المستند إذا لم يكن موجودًا
    await subjectDocRef.set({'customField': 'defaultValue'}, SetOptions(merge: true));
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("...جاري التحميل", style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final File file;
  final String title;

  const PDFViewerPage({super.key, required this.file, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}
