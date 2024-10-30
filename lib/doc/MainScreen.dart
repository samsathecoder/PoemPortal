import 'dart:async';
import 'dart:core';
import 'dart:math'; // For random number generation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'likebutton.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _BirinciView();
}

class _BirinciView extends State<MainScreen> {
  Map<String, List<String>> _listsByKey = {};
  late ValueNotifier<Map<String, bool>> _likedStatusNotifier;
  late ValueNotifier<List<int>> _likesNotifier;
  String Mauth = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = true;
  List<String> aw = [];
  late List<String> extractedValues = [];
  late DatabaseReference poemRef;
  late DatabaseReference userLikedRef;
  late StreamSubscription<DatabaseEvent> poemSubscription;
  late StreamSubscription<DatabaseEvent> userLikedSubscription;

  int currentIndex = 0;
  List<String> poemKeys = [];
  List<int> lastindex = [];

  @override
  void initState() {
    super.initState();
    poemRef = FirebaseDatabase.instance.ref("allpoem/poems/");
    userLikedRef = FirebaseDatabase.instance.ref("allpoem/userliked/$Mauth");
    _likedStatusNotifier = ValueNotifier({});
    _likesNotifier = ValueNotifier([]);
    getdata();
    likesicon();
  }

  @override
  void dispose() {
      poemSubscription.cancel();
    userLikedSubscription.cancel();
    _likedStatusNotifier.dispose();
    _likesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(50, 250, 245, 240),
      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : poemKeys.isEmpty
          ? const Center(child: Text('Gösterilecek şiir yok'))
          : Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 32.0),
                      onPressed: () {
                        setState(() {
                          if (lastindex.isEmpty) {
                            currentIndex = 0;
                          } else {
                            currentIndex = lastindex.last;
                          }
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                poemKeys[currentIndex],
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              ..._listsByKey[poemKeys[currentIndex]]!.map((line) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(line),
                              )),
                              const SizedBox(height: 16.0),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (extractedValues.isNotEmpty
                                        ? "Yazar: ${extractedValues[currentIndex]}"
                                        : 'Anonim'),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),const SizedBox(height: 16.0),
    ValueListenableBuilder<List<int>>(
    valueListenable: _likesNotifier,
    builder: (context, likes, _) {
    return Text('Beğeni: ${likes[currentIndex]}');
    },
    ),
                                  ValueListenableBuilder<Map<String, bool>>(
                                    valueListenable: _likedStatusNotifier,
                                    builder: (context, likedStatus, _) {
                                      return ValueListenableBuilder<List<int>>(
                                        valueListenable: _likesNotifier,
                                        builder: (context, likes, _) {
                                          return LikeButton(
                                            poemKey: poemKeys[currentIndex],
                                            isLiked: likedStatus[poemKeys[currentIndex]] ?? false,
                                            likeCount: likes[currentIndex],
                                            onLikeToggle: () {
                                              liked(poemKeys[currentIndex]);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 32.0),
                      onPressed: () {
                        setState(() {
                          lastindex.add(currentIndex);
                          int randomIndex = Random().nextInt(poemKeys.length);
                          currentIndex = randomIndex;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      savePoem();
                    },
                    child: const Text('Şiiri Kaydet', style: TextStyle(fontSize: 14.0, color: Colors.black87)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getdata() {
    poemSubscription = poemRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        Map<String, List<String>> tempMap = {};
        List<int> tempLikes = [];
        List<String> tempKeys = [];
        aw.clear();

        data.forEach((key, value) {
          final poemData = value as Map<dynamic, dynamic>?;
          if (poemData != null) {
            List<String> lines = [];
            bool isVisible = true;

            poemData.forEach((subKey, subValue) {
              if (subKey == "info") {
                final infoData = subValue as Map<dynamic, dynamic>?;
                if (infoData != null) {
                  isVisible = infoData['visible'] ?? true;

                  final filteredEntries1 = infoData.entries.where((entry) => entry.key == 'likes');
                  final filteredData1 = Map<dynamic, dynamic>.fromEntries(filteredEntries1);

                  tempLikes.add(filteredData1.isNotEmpty ? filteredData1.values.first as int : 0);
                  final filteredEntries = infoData.entries.where((entry) => entry.key != 'likes');
                  final filteredData = Map<dynamic, dynamic>.fromEntries(filteredEntries);
                  aw.add(filteredData.toString());

                  extractedValues = aw.map((item) {
                    const prefix = 'yazar: ';
                    int startIndex = item.indexOf(prefix) + prefix.length;
                    if (startIndex > prefix.length - 1) {
                      return item.substring(startIndex, item.length - 1);
                    }
                    return '';
                  }).toList();
                }
              } else if (subKey != "info") {
                lines.add(subValue.toString());
              }
            });

            if (isVisible && lines.isNotEmpty) {
              tempMap[key] = lines;
              tempKeys.add(key);
            }
          }
        });

        if (mounted) {
          setState(() {
            _listsByKey = tempMap;
            _isLoading = false;
            _likesNotifier.value = tempLikes;
            _likedStatusNotifier.value = {for (var key in tempMap.keys) key: false};
            poemKeys = tempKeys;
            currentIndex = 0;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          poemKeys = [];
        });
      }
    });
  }

  void likesicon() {
    userLikedSubscription = userLikedRef.onValue.listen((onData) {
      if (onData.snapshot.exists) {
        final data = onData.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          Map<String, bool> updatedDataMap = {};
          data.forEach((key, value) {
            if (value is bool) {
              updatedDataMap[key.toString()] = value;
            }
          });

          if (mounted) {
            setState(() {
              _likedStatusNotifier.value = updatedDataMap;
            });
          }
        }
      }
    });
  }

  Future<void> liked(String poemKey) async {
    final currentLikeStatus = _likedStatusNotifier.value[poemKey] ?? false;
    final newLikeStatus = !currentLikeStatus;
    final currentLikes = _likesNotifier.value;
    final newLikeCount = newLikeStatus ? currentLikes[currentIndex] + 1 : currentLikes[currentIndex] - 1;

    await poemRef.child('$poemKey/info/likes').set(newLikeCount);
    await userLikedRef.child(poemKey).set(newLikeStatus);

    setState(() {
      _likedStatusNotifier.value = {..._likedStatusNotifier.value, poemKey: newLikeStatus};
      _likesNotifier.value = List.from(currentLikes)..[currentIndex] = newLikeCount;
    });
  }

  Future<void> savePoem() async {
    if (poemKeys.isNotEmpty) {
      final currentPoemKey = poemKeys[currentIndex];
      final DatabaseReference savedPoemsRef = FirebaseDatabase.instance.ref("allpoem/saved/$Mauth");

      try {
        await savedPoemsRef.child(currentPoemKey).set(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şiir kaydedildi!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hata Oluştu.')),
        );
      }
    }
  }
}
