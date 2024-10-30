import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:google_fonts/google_fonts.dart';

import 'doc/MainScreen.dart';
import 'doc/PersonalPage.dart';
import 'doc/WritingPage.dart';
import 'package:poemportal/doc/deneme.dart';
// Ensure to import the correct file

class MyApp extends StatelessWidget {
  const MyApp({super.key});




  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      supportedLocales: const <Locale>[
        Locale('en', 'US'), // American English
        Locale('tr', 'TR'), // Israeli Hebrew
        // ...
      ],
      theme: ThemeData(
        useMaterial3: true,


        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,

          brightness: Brightness.dark,
        ),

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          // ···
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      title: 'Şiir Portalı',
      home:  const MyHomePage(title: '',),
    );
  }
}

class MyHomePage extends StatefulWidget {
   const MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage>with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;

  int secilenItem = 0;
  late List<Widget> tumSayfalarim;
  late MainScreen mainpage;
  late WritePage postingpage;
  late PersonalPage personalpage;
  late About deneme;

  @override
  void initState() {
    super.initState();
    mainpage = const MainScreen();
    postingpage = const WritePage();
    personalpage = const PersonalPage();
    deneme = const About();
    tumSayfalarim = [mainpage, postingpage, personalpage, deneme];
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 4, vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController!.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blue[400],
              shadowColor: Colors.transparent,
              elevation: 10.0,
              centerTitle: false,
              scrolledUnderElevation: 1.0,
              toolbarHeight: 60.0,
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.normal),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    // Handle menu selection
                  },

          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'Option 1',
                      child: const Text('Portal hakkında'),onTap: () {
                      _motionTabBarController!.index = 3;
                      }


                    ),
                    PopupMenuItem<String>(
                      value: 'Option 2',
                      child: const Text('Çıkış yap'),onTap: () => signout(),
                    ),

                  ],


                ),
              ],
              title: Text(
                "Merhaba ${FirebaseAuth.instance.currentUser?.displayName ?? 'Kullanıcı'}",
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              floating: true,
              snap: true,

            ),
          ];
        },
        body:TabBarView(
          physics: const NeverScrollableScrollPhysics(), // swipe navigation handling is not supported
          // controller: _tabController,
          controller: _motionTabBarController,
          children: <Widget>[
           mainpage,
            postingpage,
            personalpage,
            deneme
          ],
        ),
      ),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController, // ADD THIS if you need to change your tab programmatically
        initialSelectedTab: "Ana Sayfa",
        labels: const ["Ana Sayfa", "Şiir Yaz","Profilim"],
        icons: const [Icons.dashboard, Icons.add_circle, Icons.person_sharp],

        // optional badges, length must be same with labels

        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: Colors.blue[200],
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: Colors.blue[400],
        tabIconSelectedColor: Colors.white,
        tabBarColor: Colors.white,
        onTabItemSelected: (int value) {
          setState(() {
            // _tabController!.index = value;
            _motionTabBarController!.index = value;
          });
        },
      ),





     /** bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        currentIndex: secilenItem,
        onTap: (index) {
          setState(() {
            secilenItem = index;
          });
        },
        selectedFontSize: 16,
        backgroundColor: Colors.teal.shade50,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(color: Colors.grey.shade600),
        iconSize: 24,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.teal.shade100,
            icon: Icon(Icons.home),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: "Şiir Yaz",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profilim",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Deneme",
          ),
        ],
      ),**/
    );
  }

  signout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacementNamed('login');
  }
}
