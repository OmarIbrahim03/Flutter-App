import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SentimentTabsPage extends StatefulWidget {
  const SentimentTabsPage({super.key});

  @override
  State<SentimentTabsPage> createState() => _SentimentTabsPageState();
}

class _SentimentTabsPageState extends State<SentimentTabsPage> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  File? selectedImage;

  Future<void> pickImage() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sentiment Analysis"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Text"),
              Tab(text: "Image"),
              Tab(text: "Link"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Text Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Enter your text",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle text submission
                      print("Text submitted: ${textController.text}");
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ),

            // Image Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: pickImage,
                    child: const Text("Upload an Image"),
                  ),
                  const SizedBox(height: 16),
                  if (selectedImage != null)
                    Image.file(
                      selectedImage!,
                      height: 150,
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle image submission
                      print("Image submitted: ${selectedImage?.path}");
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ),

            // Link Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: linkController,
                    decoration: const InputDecoration(
                      labelText: "Enter a link",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle link submission
                      print("Link submitted: ${linkController.text}");
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
