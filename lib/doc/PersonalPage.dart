import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'editpoem.dart'; // Assuming this file is in a 'doc' directory
import 'savedpoems.dart';
class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>  with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  late Map visibility = {}; // Use Map<String, bool> to track expansion

  Map<String, List<String>> _listsByKey = {};
  final Map<String, bool> _expandedKeys = {}; // Use Map<String, bool> to track expansion
  final String? Mauth = FirebaseAuth.instance.currentUser?.uid;
  late Map<String, bool> visibilityMap;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchFilteredData(); // Fetch data for My Poems tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar:   TabBar(
        controller: _tabController,
          tabs: const [
            Tab( child: Text( 'Şiirlerim',style: TextStyle(fontSize: 18.0,color: Colors.black87))  ),
            Tab( child: Text( 'Kaydedilenler',style: TextStyle(fontSize: 18.0,color: Colors.black87))),
          ],
        ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyPoemsPage(),
          const SavedPoemsPage(),
        ],
      ),
    );
  }

  Widget _buildMyPoemsPage() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _listsByKey.isEmpty
        ? const Center(child: Text(' şiiriniz bulunmamaktadır.'))
        : ListView.builder(
      itemCount: _listsByKey.length,

      itemBuilder: (context, index) {
        final key = _listsByKey.keys.elementAt(index);
        final list = _listsByKey[key]!;
        final isVisible = visibilityMap[key] ?? false; // Get visibility status
        final isExpanded = _expandedKeys[key] ?? false;
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(' $key '),
                subtitle: Text(isVisible? "Yayında":"Onay bekliyor"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      onPressed: () {
                        setState(() {
                          _expandedKeys[key] = !isExpanded;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPoemPage(
                              poemKey: key,
                              poemLines: list,
                              onUpdate: (updatedLines) {
                                setState(() {
                                  _listsByKey[key] = updatedLines;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmationDialog(key);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _expandedKeys[key] = !isExpanded;
                  });
                },
              ),
              if (isExpanded)
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
    );
  }

  Future<void> fetchFilteredData() async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref("allpoem/poems");
      final snapshot = await databaseReference.get();

      if (!snapshot.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;

      Map<String, List<String>> tempMap = {};
      visibilityMap = {}; // Initialize visibilityMap

      data.forEach((key, value) {
        final valueMap = value as Map<dynamic, dynamic>;

        if (value.containsKey('info') && value['info']['uid'] == Mauth) {
          valueMap.forEach((subKey, subValue) {
            if (subKey == "info") {
              final infoData = subValue as Map<dynamic, dynamic>?;
              if (infoData != null) {
                // Get the visibility status for this poem
                final isVisible = infoData['visible'] ?? true;
                visibilityMap[key] = isVisible; // Update visibilityMap
              }
            }
          });

          valueMap.remove("info");
          List<String> lines = [];
          valueMap.forEach((subKey, subValue) {
            lines.add(subValue.toString());
          });
          if (lines.isNotEmpty) {
            tempMap[key] = lines;
          }
        }
      });


      setState(() {
        _listsByKey = tempMap;
        _isLoading = false;
      });
    } catch (e) {
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
          title: const Text('Şiiri sil'),
          content: const Text('Bu şiir kalıcı olarak silinecektir, Onaylıyor musunuz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deletePoem(poemKey); // Perform the delete action
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePoem(String poemKey) async {

      final databaseReference = FirebaseDatabase.instance.ref("allpoem/poems/$poemKey");
      await databaseReference.remove(); // Delete the poem from the database

      // Remove the poem from the local state
      setState(() {
        _listsByKey.remove(poemKey);
      });


  }
}
