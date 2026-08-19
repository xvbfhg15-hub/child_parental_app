import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ====== إعدادات Firebase المدمجة من كود JavaScript ======
  // تم تحويل firebaseConfig إلى FirebaseOptions
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCsRl3Pc3eEJgrgZLYtDZ-91Ir5MzFMw8c",
      authDomain: "parentalcontrol-f192f.firebaseapp.com",
      databaseURL: "https://parentalcontrol-f192f-default-rtdb.firebaseio.com",
      projectId: "parentalcontrol-f192f",
      storageBucket: "parentalcontrol-f192f.firebasestorage.app",
      messagingSenderId: "375107383090",
      appId: "1:375107383090:web:2818ec6aec79fd95fcb12b",
      measurementId: "G-RDT7S5G4CP",
    ),
  );

  runApp(const MyApp());
}

// ==================== الألوان والهوية البصرية ====================
class AppColors {
  static const bg = Color(0xFF0B1220);
  static const surface = Color(0xFF152036);
  static const surfaceRaised = Color(0xFF1C2A47);
  static const accent = Color(0xFF22D3EE); // سماوي - الحماية النشطة
  static const warning = Color(0xFFF59E0B); // كهرماني - التنبيهات
  static const danger = Color(0xFFEF4444); // أحمر - الخطر
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF8DA0C0);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام حماية الطفل',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          background: AppColors.bg,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const AuthGate(),
    );
  }
}

// ==================== بوابة التحقق من تسجيل الدخول ====================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// ==================== شاشة تسجيل الدخول ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isRegisterMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegisterMode) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل مسبقاً';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، استخدم 6 أحرف على الأقل';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1220), Color(0xFF101B33)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.12),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.4),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.shield_rounded,
                          color: AppColors.accent, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'نظام حماية الطفل',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRegisterMode
                          ? 'أنشئ حساب ولي الأمر للمتابعة'
                          : 'سجّل الدخول لمتابعة جهاز طفلك',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _emailCtrl,
                      hint: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'أدخل البريد الإلكتروني';
                        if (!v.contains('@')) return 'بريد إلكتروني غير صالح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _passCtrl,
                      hint: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'كلمة المرور 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.danger.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.danger, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_errorMessage!,
                                  style: const TextStyle(
                                      color: AppColors.danger, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: const Color(0xFF001018),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Color(0xFF001018)),
                              )
                            : Text(
                                _isRegisterMode                            : Text(
                                _isRegisterMode ? 'إنشاء حساب' : 'تسجيل الدخول',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          setState(() => _isRegisterMode = !_isRegisterMode),
                      child: Text(
                        _isRegisterMode
                            ? 'لديك حساب بالفعل؟ سجّل الدخول'
                            : 'ليس لديك حساب؟ أنشئ واحداً',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
      ),
    );
  }
}

// ==================== الشاشة الرئيسية ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool isWebFilterActive = true;
  bool isApkBlockerActive = true;

  String get _parentEmail =>
      FirebaseAuth.instance.currentUser?.email ?? 'غير معروف';

  Future<void> _sendSecurityAlert(String alertType, String details) async {
    await _database.child('alerts').push().set({
      'type': alertType,
      'details': details,
      'timestamp': ServerValue.timestamp,
      'parentEmail': _parentEmail,
    });

    if (mounted) {
      _showSnack('تم تسجيل التنبيه: $alertType', AppColors.accent);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.4))),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final protectionOn = isWebFilterActive && isApkBlockerActive;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildHeader(protectionOn),
              const SizedBox(height: 20),
              _buildStatusCard(protectionOn),
              const SizedBox(height: 20),
              _buildToggleCard(
                title: 'حظر المواقع الإباحية والمشبوهة',
                subtitle: 'تفعيل فلترة DNS لحماية التصفح',
                icon: Icons.public_off_rounded,
                value: isWebFilterActive,
                onChanged: (val) {
                  setState(() => isWebFilterActive = val);
                  _sendSecurityAlert(
                      'فلترة الشبكة', val ? 'تم التفعيل' : 'تم الإيقاف');
                },
              ),
              const SizedBox(height: 12),
              _buildToggleCard(
                title: 'منع تثبيت ملفات APK الخارجية',
                subtitle: 'حظر التثبيت من مصادر غير معروفة',
                icon: Icons.android_rounded,
                value: isApkBlockerActive,
                onChanged: (val) {
                  setState(() => isApkBlockerActive = val);
                  _sendSecurityAlert(
                      'منع APK', val ? 'تم التفعيل' : 'تم الإيقاف');
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('سجل التنبيهات المباشر'),
              const SizedBox(height: 10),
              _buildAlertsList(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _sendSecurityAlert(
                      'اختبار', 'تنبيه تجريبي من جهاز الطفل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('إرسال تنبيه تجريبي للوالدين'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool protectionOn) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (protectionOn ? AppColors.accent : AppColors.warning)
                .withOpacity(0.14),
          ),
          child: Icon(Icons.shield_rounded,
              color: protectionOn ? AppColors.accent : AppColors.warning),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('نظام الحماية والمراقبة',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              Text(_parentEmail,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
          tooltip: 'تسجيل الخروج',
        ),
      ],
    );
  }

  Widget _buildStatusCard(bool protectionOn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: protectionOn
              ? [const Color(0xFF0E3A45), const Color(0xFF14293D)]
              : [const Color(0xFF45330E), const Color(0xFF291E14)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            protectionOn ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
            color: protectionOn ? AppColors.accent : AppColors.warning,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  protectionOn ? 'الحماية مفعّلة بالكامل' : 'الحماية غير مكتملة',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  protectionOn
                      ? 'جميع أنظمة الحماية تعمل بشكل طبيعي'
                      : 'بعض الحمايات متوقفة، راجع الإعدادات',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.accent,
        secondary: Icon(icon,
            color: value ? AppColors.accent : AppColors.textSecondary),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700));
  }

  Widget _buildAlertsList() {
    final alertsQuery =
        _database.child('alerts').orderByChild('timestamp').limitToLast(20);

    return StreamBuilder<DatabaseEvent>(
      stream: alertsQuery.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.accent)),
          );
        }

        final raw = snapshot.data?.snapshot.value;
        if (raw == null) {
          return _emptyAlertsState();
        }

        final map = Map<String, dynamic>.from(raw as Map);
        final entries = map.entries.toList()
          ..sort((a, b) {
            final ta = (a.value['timestamp'] ?? 0) as int;
            final tb = (b.value['timestamp'] ?? 0) as int;
            return tb.compareTo(ta);
          });

        return Column(
          children: entries.map((e) {
            final alert = Map<String, dynamic>.from(e.value);
            return _alertTile(alert);
          }).toList(),
        );
      },
    );
  }

  Widget _emptyAlertsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_off_outlined,
              color: AppColors.textSecondary, size: 28),
          SizedBox(height: 8),
          Text('لا توجد تنبيهات حتى الآن',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _alertTile(Map<String, dynamic> alert) {
    final type = alert['type']?.toString() ?? 'تنبيه';
    final details = alert['details']?.toString() ?? '';
    final email = alert['parentEmail']?.toString();
    final ts = alert['timestamp'];
    String timeLabel = '';
    if (ts is int) {
      final date = DateTime.fromMillisecondsSinceEpoch(ts);
      timeLabel = DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(date);
    }

    final iconData = _iconForType(type);
    final color = _colorForType(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(right: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5)),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(details,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12.5)),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (timeLabel.isNotEmpty) ...[
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(timeLabel,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                    ],
                    if (email != null && email != 'غير معروف') ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.person_outline_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    if (type.contains('فلترة')) return Icons.public_off_rounded;
    if (type.contains('APK')) return Icons.android_rounded;
    if (type.contains('اختبار')) return Icons.warning_amber_rounded;
    return Icons.notifications_active_rounded;
  }

  Color _colorForType(String type) {
    if (type.contains('اختبار')) return AppColors.warning;
    return AppColors.accent;
  }
}
