import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutPageState();
}

class _AboutPageState extends State<About> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _sendFeedback() async{
    final feedback = _feedbackController.text;
    if (feedback.isNotEmpty) {

      try {
        final databaseReference = FirebaseDatabase.instance.ref(
            "allpoem/feedbacks/${FirebaseAuth.instance.currentUser!.displayName}");
        databaseReference.push().child("mesaj").set(feedback.toString());


      }catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hata Oluştu.')),
        );    }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderildi!')),
      );

      _feedbackController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen mesajınızı girin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Şiir portalı hakkında-Nasıl Kullanılır',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Example Text
            Text(
              'Şiir portalı herkese açık olarak şiir paylaşabileceğiniz bir platformdur. Yazın, paylaşın beğenilsin, beğenin '
                    'İster anonim olarak paylaşın, ister kullanıcı adınızla Şiirleriniz kontrol sonrası ana sayfaya düşeçektir.'
              'Görüşleriniz değerlidir, Lütfen uygulamayı değerlendirin Geliştirmek için ve her türlü uygulama içi sorun yaşamanız durumunda aşağıda bulunan '
                  'mesaj alanından düşüncelerinizi paylaşın.',

              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 8.0),

            const SizedBox(height: 8.0),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Görüşlerinizi buraya yazabilirsiniz...',
              ),
            ),
             const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendFeedback,
              child: const Text('Gönder',style: TextStyle(color: Colors.black87),),
            ),
            const Divider(),
            const SizedBox(height: 16.0),

            // Developer Contact Card
           Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İletişim',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Uygulama sahibi ile iletişime geçmek için',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Email:alfreidsamsa@gmail.com',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                  ],
                ),
              ),


            // Feedback Section

          ],
        ),
      ),
    );
  }
}
