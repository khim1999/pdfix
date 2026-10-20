import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'services/security_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await SecurityService.instance.init();
  runApp(const PdfToolkitApp());
}

class PdfToolkitApp extends StatefulWidget {
  const PdfToolkitApp({super.key});

  @override
  State<PdfToolkitApp> createState() => _PdfToolkitAppState();
}

class _PdfToolkitAppState extends State<PdfToolkitApp> with WidgetsBindingObserver {
  final _sec = SecurityService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sec.addListener(_onSecurityChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sec.removeListener(_onSecurityChange);
    super.dispose();
  }

  void _onSecurityChange() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _sec.lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDFix',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (_sec.isLocked)
              Positioned.fill(
                child: LockScreen(
                  onUnlocked: () {
                    _sec.unlock();
                  },
                ),
              ),
          ],
        );
      },
      home: const HomeScreen(),
    );
  }
}
