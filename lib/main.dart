import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCsRl3Pc3eEJgrgZLYtDZ-91Ir5MzFMw8c",
      appId: "1:375107383090:web:2818ec6aec79fd95fcb12b",
      messagingSenderId: "375107383090",
      projectId: "parentalcontrol-f192f",
      databaseURL: "https://parentalcontrol-f192f-default-rtdb.firebaseio.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('تطبيق الحماية - الابن')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              DatabaseReference ref = FirebaseDatabase.instance.ref("alerts").push();
              await ref.set({
                "message": "محاولة فتح تطبيق محظور",
                "time": DateTime.now().toString(),
              });
            },
            child: const Text('إرسال تنبيه تجريبي للوحة الأب'),
          ),
        ),
      ),
    );
  }
}
