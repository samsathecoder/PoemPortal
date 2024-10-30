import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SavedPoemsPage extends StatefulWidget {
  const SavedPoemsPage({super.key});

  @override
  State<SavedPoemsPage> createState() => _SavedPoemsPageState();
}

class _SavedPoemsPageState extends State<SavedPoemsPage> {
  bool _isLoading = true;
  Map<String, List<String>> _savedPoems = {};
  final String? Mauth = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchSavedPoems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedPoems.isEmpty
          ? const Center(child: Text('No saved poems available'))
          : ListView.builder(
        itemCount: _savedPoems.length,
        itemBuilder: (context, index) {
          final key = _savedPoems.keys.elementAt(index);
          final list = _savedPoems[key]!;

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(' $key'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(key);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: list.map((line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(line),
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> fetchSavedPoems() async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref("allpoem/saved/$Mauth");
      final snapshot = await databaseReference.get();

      if (!snapshot.exists) {
        print('No saved poems found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;

      Map<String, List<String>> tempMap = {};

      for (var key in data.keys) {
        final poemRef = FirebaseDatabase.instance.ref("allpoem/poems/$key");
        final poemSnapshot = await poemRef.get();
        final valueMap = poemSnapshot.value as Map<dynamic, dynamic>;
        valueMap.remove('info');
        List<String> lines = [];
        valueMap.forEach((subKey, subValue) {
          lines.add(subValue.toString());
        });
        if (lines.isNotEmpty) {
          tempMap[key] = lines;
        }
      }

      setState(() {
        _savedPoems = tempMap;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching saved poems: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showDeleteConfirmationDialog(String poemKey) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kaydedilenlerden kaldır'),
          content: const Text('Seçili şiir kaydedilenler listesinden kaldıralacaktır, onaylıyor musunuz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('hayır'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('evet'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteSavedPoem(poemKey); // Perform the delete action
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSavedPoem(String poemKey) async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref("allpoem/saved/$Mauth/$poemKey");
      await databaseReference.remove(); // Delete the poem from saved list

      // Remove the poem from the local state
      setState(() {
        _savedPoems.remove(poemKey);
      });

      print('Saved poem deleted successfully');
    } catch (e) {
      print('Error deleting saved poem: $e');
    }
  }
}
