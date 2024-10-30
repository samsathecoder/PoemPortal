
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:poemportal/homescreen.dart';


import 'login/loginp.dart';
import 'login/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      routes: {
        'login': (context) => const MyLogin(),
        'register': (context) => const MyRegister(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While Firebase is initializing and the auth state is loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle any errors during authentication
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData) {
          // If the user is not logged in
          return const MyLogin(); // Or use Navigator to push to 'login' route
        }
        else {
          // If the user is logged in
          return const MyHomePage(title: "title"); // Or use Navigator to push to 'home' route
        }
      },
    );
  }}

/*
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
    if (user == null) {
      runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home:MyLogin(),
      routes: {
        'login': (context) => MyLogin(),
        'register' : (context)=> MyRegister(),
      },
    ));
    } else {
run();
    }
  });





}
void run(){

  runApp(MaterialApp(


    debugShowCheckedModeBanner: false,
    home:MyHomePage(title: FirebaseAuth.instance.currentUser!.displayName.toString(),),

  ));


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poem Portal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
     home: const MyHomePage(title: 'Poem Portal Yaz ve Gönder'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int secilenItem = 0;
  late List<Widget> tumSayfalarim;
  late BirinciView birinciSayfa;
  late IkinciView ikinciSayfa;
  late UcuncuView ucuncuSayfa;
  // FirebaseDatabase database = FirebaseDatabase.instance;

  //late UcuncuView ucuncuSayfa;

  @override
  void initState() {
    super.initState();
    birinciSayfa = const BirinciView();
    ikinciSayfa =  IkinciView();
    ucuncuSayfa =  UcuncuView();

    tumSayfalarim = [birinciSayfa,ucuncuSayfa,ikinciSayfa];
  }



  @override
  Widget build(BuildContext context) {

    return  Scaffold(backgroundColor: Colors.teal,
      appBar: AppBar(
        title: Text(widget.title),
      ),

      bottomNavigationBar:  BottomNavigationBar(
        showUnselectedLabels: true,
        currentIndex: secilenItem,
        onTap: (index) {
          setState(() {
            secilenItem = index;
          });
        },
        selectedFontSize: 15,
        backgroundColor: Colors.limeAccent,showSelectedLabels: true,
        mouseCursor: MouseCursor.uncontrolled,
        type: BottomNavigationBarType.shifting,
        iconSize: 25,

        fixedColor: Colors.white70,
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor:Colors.lime.shade400,
            icon: Icon (  Icons.home),
            label: "anasayfa",
          ),

          BottomNavigationBarItem(
            icon :( Icon(  Icons.add_circle_outline_rounded)),
            label: "Şiirini Yaz",


          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profilim",

          ),
        ],
      ),



      body:

      tumSayfalarim[secilenItem],// This trailing comma makes auto-formatting nicer for build methods.
    );
  }





}*/




