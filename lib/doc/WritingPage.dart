import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:poemportal/homescreen.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});
  @override
  State<WritePage> createState() => _WritePageState();
}
class _WritePageState extends State<WritePage> {
  final TextEditingController siirController = TextEditingController();
  final TextEditingController baslikController = TextEditingController();
  List<String> sentences = [];
  String baslikP = "";
  bool baslikvarmi = true;
  bool siirblok = false;
  bool isEditingTitle = false;
  bool isAnonymous = false; // Track anonymity
  String? user = FirebaseAuth.instance.currentUser?.displayName;
  late FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController(); // Add ScrollController

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {

    siirController.dispose();
    baslikController.dispose();
    _focusNode.dispose();
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

      void _onFocusChange() {
        if (!_focusNode.hasFocus && isEditingTitle) {
          setState(() {
            baslikP = baslikController.text;
            isEditingTitle = false;
            baslikvarmi = false;
            siirblok = true;
          });
        }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: isEditingTitle
                      ? TextField(
                    controller: baslikController,
                    autofocus: true,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Şiir Başlığınızı Yazın...',
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        baslikP = value;
                        isEditingTitle = false;
                        baslikvarmi = false;
                        siirblok = true;
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        baslikP = baslikController.text;
                        isEditingTitle = false;
                        baslikvarmi = false;
                        siirblok = true;
                      });
                    },
                  )
                      : GestureDetector(
                    onTap: () {
                      setState(() {
                        isEditingTitle = true;
                        baslikController.text = baslikP; // Set the current title in the TextField
                      });
                    },
                    child: Text(
                      baslikP.isNotEmpty
                          ? baslikP
                          : "Başlığınızı eklemek için tıklayın ",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              // Poem Lines Section
              if (siirblok)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6, // Adjust height
                        child: ListView(
                          controller: _scrollController,
                          children: sentences.map((sentence) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                sentence,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ), Row(
                        children: [
                          Expanded(
                            child: TextField(
                              maxLines: 1,
                              controller: siirController,
                              maxLength: 100,
                              decoration: const InputDecoration(
                                hintText: 'Şiirinizi satır satır ekleyiniz...',
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              iconColor: Colors.blueGrey,
                              foregroundColor: Colors.blueGrey,
                              backgroundColor: Colors.white,
                              shadowColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (siirController.text.isNotEmpty) {
                                  sentences.add(siirController.text);
                                  siirController.clear();
                                  _scrollToBottom(); // Scroll to bottom when new text is added
                                }
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text(
                              "Ekle",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Anonim olarak'),
                          Checkbox(
                            value: isAnonymous,
                            onChanged: (bool? value) {
                              setState(() {
                                isAnonymous = value ?? false;
                              });
                            },
                          ),
                          const Text("Paylaş"),
                          Center(
                            child: IconButton(
                              onPressed: () async {
                                bool success = await addrd();
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Şiir başarıyla eklendi!')),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MyHomePage(title: ''),
                                    ),
                                  );

                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Bir hata oluştu. Lütfen tekrar deneyin.')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.send),
                              tooltip: "Gönder",
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),

    );
  }

  Future<bool> addrd() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref("allpoem").child("poems")
          .child(baslikP);

      // Use 'anonim' if isAnonymous is true, otherwise use the user displayName
      final author = isAnonymous ? 'anonim' : user;

      await ref.set(sentences.asMap());
      await ref.child("info").set({
        "likes": 0,
        "yazar": author,
        "uid": FirebaseAuth.instance.currentUser?.uid,
        "visible": false,
      });
      sentences.clear();
      return true; // Indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hata oluştu.')),
      );      return false; // Indicate failure
    }
  }
}
