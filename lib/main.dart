import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الفايربيس باستخدام البيانات الخاصة ببرنامجك
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
      title: 'تطبيق حماية الطفل',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool isWebFilterActive = true;
  bool isApkBlockerActive = true;

  // إرسال تنبيه أو خرق أمني إلى الفايربيس
  Future<void> _sendSecurityAlert(String alertType, String details) async {
    await _database.child('alerts').push().set({
      'type': alertType,
      'details': details,
      'timestamp': ServerValue.timestamp,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تسجيل التنبيه: $alertType')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام الحماية والمراقبة'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // قسم فلترة الشبكة والمواقع
            SwitchListTile(
              title: const Text('حظر المواقع الإباحية والمشبوهة'),
              subtitle: const Text('تفعيل فلترة DNS لحماية التصفح'),
              value: isWebFilterActive,
              onChanged: (val) {
                setState(() => isWebFilterActive = val);
                _sendSecurityAlert('فلترة الشبكة', val ? 'تم التفعيل' : 'تم الإيقاف');
              },
            ),
            const Divider(),

            // قسم منع التطبيقات الخارجية
            SwitchListTile(
              title: const Text('منع تثبيت ملفات APK الخارجية'),
              subtitle: const Text('حظر التثبيت من مصادر غير معروفة'),
              value: isApkBlockerActive,
              onChanged: (val) {
                setState(() => isApkBlockerActive = val);
                _sendSecurityAlert('منع APK', val ? 'تم التفعيل' : 'تم الإيقاف');
              },
            ),
            const Divider(),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _sendSecurityAlert('اختبار', 'تنبيه تجريبي من جهاز الطفل'),
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('إرسال تنبيه تجريبي للوالدين'),
            ),
          ],
        ),
      ),
    );
  }
}
