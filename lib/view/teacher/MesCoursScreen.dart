import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddCourseMaterialScreen extends StatefulWidget {
  final String teacherId;

  const AddCourseMaterialScreen({Key? key, required this.teacherId}) : super(key: key);

  @override
  State<AddCourseMaterialScreen> createState() => _AddCourseMaterialScreenState();
}

class _AddCourseMaterialScreenState extends State<AddCourseMaterialScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedGroupId;
  File? selectedFile;
  bool isLoading = false;
  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    loadGroups();
  }

  Future<void> loadGroups() async {
    final response = await Supabase.instance.client
        .from('groups')
        .select()
        .eq('teacher_id', widget.teacherId);
    setState(() {
      groups = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitCourse() async {
    if (selectedGroupId == null || titleController.text.isEmpty || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select a file.")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Upload file
    final fileName = '${const Uuid().v4()}_${selectedFile!.path.split('/').last}';
    final fileBytes = await selectedFile!.readAsBytes();
    final storageResponse = await Supabase.instance.client.storage
        .from('courses')
        .uploadBinary('materials/$fileName', fileBytes);

    final fileUrl = Supabase.instance.client.storage.from('courses').getPublicUrl('materials/$fileName');

    // Save to database
    await Supabase.instance.client.from('courses').insert({
      'teacher_id': widget.teacherId,
      'group_id': selectedGroupId,
      'title': titleController.text,
      'description': descriptionController.text,
      'file_url': fileUrl,
      'created_at': DateTime.now().toIso8601String(),
    });

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2FF),
      appBar: AppBar(
        title: const Text('Add Course Material'),
        backgroundColor: const  Color(0xFF8E9EFB),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedGroupId,
              hint: Text("Select Group"),
              items: groups.map((group) {
                return DropdownMenuItem<String>(
                  value: group['id'],
                  child: Text(group['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedGroupId = value),
              decoration: InputDecoration(border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Course Title', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Description', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload File"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E9EFB)),
            ),
            if (selectedFile != null) Text(selectedFile!.path.split('/').last),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : submitCourse,
              child: isLoading ? CircularProgressIndicator(color: Colors.white) : const Text("Submit Course"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Color(0xFF8E9EFB)),
            )
          ],
        ),
      ),
    );
  }
}

class FileType {
  static var any;
}

class FilePicker {
  static var platform;
}
