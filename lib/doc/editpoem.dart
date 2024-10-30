import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EditPoemPage extends StatefulWidget {
  final String poemKey; // This should be the title of the poem
  final List<String> poemLines;
  final Function(List<String>) onUpdate;

  const EditPoemPage({
    required this.poemKey,
    required this.poemLines,
    required this.onUpdate,
    super.key,
  });

  @override
  _EditPoemPageState createState() => _EditPoemPageState();
}

class _EditPoemPageState extends State<EditPoemPage> {
  late List<TextEditingController> _controllers;
  late List<String> _lines;

  @override
  void initState() {
    super.initState();
    _lines = List.from(widget.poemLines);
    _controllers = _lines.map((line) => TextEditingController(text: line)).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şiirleri Düzenle')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: TextFormField(
                    controller: _controllers[index],
                    decoration: InputDecoration(
                      labelText: 'Satır ${index + 1}',
                    ),
                    maxLines: null,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteLine(index);
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _addLine,
            child: const Text('Satır Ekle',style: TextStyle(color: Colors.black87),),
          ),
          ElevatedButton(
            onPressed: _savePoem,
            child: const Text('Kaydet',style: TextStyle(color: Colors.black87),),
          ),
        ],
      ),
    );
  }

  void _addLine() {
    setState(() {
      _lines.add('');
      _controllers.add(TextEditingController());
    });
  }

  void _deleteLine(int index) {
    setState(() {
      _lines.removeAt(index);
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  Future<void> _savePoem() async {
    final updatedLines = _controllers.map((controller) => controller.text).toList();

    try {
      final databaseReference = FirebaseDatabase.instance.ref("allpoem/poems/${widget.poemKey}");

      // Update the poem lines
      final updates = Map<String, String>.fromIterables(
        List.generate(updatedLines.length, (index) => index.toString()),
        updatedLines,
      );

      await databaseReference.update(updates);

      // Optionally update other information if needed
      await databaseReference.child("info").update({
        "lastUpdated": DateTime.now().toIso8601String(),
      });

      widget.onUpdate(updatedLines); // Notify the parent widget
      Navigator.pop(context); // Close the edit page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hata Oluştu.')),
      );    }
  }
}
