import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:pos_indorep/provider/dashboard_provider.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:pos_indorep/provider/web/warnet_backend_provider.dart';
import 'package:pos_indorep/provider/web/web_main_provider.dart';
import 'package:pos_indorep/provider/web/web_transaksi_provider.dart';
import 'package:pos_indorep/screen/home_screen.dart';
import 'package:pos_indorep/web/screen/warnet_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAeR0FuthfHhmNg221oGLzY6f8vBBqRQmc",
          authDomain: "pariwisata-cireong.firebaseapp.com",
          projectId: "pariwisata-cireong",
          storageBucket: "pariwisata-cireong.appspot.com",
          messagingSenderId: "1081014321686",
          appId: "1:1081014321686:web:73f179db5c144f37386b37",
          measurementId: "G-ZGYP2QXW1K"),
    );
  } else {
    await Firebase.initializeApp();
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => WebTransaksiProvider()),
        ChangeNotifierProvider(create: (_) => WebMainProvider()),
        ChangeNotifierProvider(create: (_) => WarnetBackendProvider()),
      ],
      child: GlobalLoaderOverlay(child: kIsWeb ? MyWebApp() : MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Indorep',
      themeMode: ThemeMode.dark, // Change this to ThemeMode.system for auto
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: IndorepColor.primary,
          brightness: Brightness.light, // Light Mode
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: IndorepColor.primary,
          brightness: Brightness.dark, // Dark Mode
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyWebApp extends StatelessWidget {
  const MyWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'INDOREP Net',
      themeMode: ThemeMode.dark, // Change to ThemeMode.system for auto
      theme: FluentThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      home: const WarnetHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
