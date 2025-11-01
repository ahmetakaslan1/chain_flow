import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain/providers/project_provider.dart';
import 'package:chain/services/hive_service.dart';
import 'package:chain/screens/home_page.dart';
import 'package:chain/providers/theme_provider.dart';
import 'package:hive/hive.dart';
import 'package:chain/services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chain/l10n/app_localizations.dart';
import 'package:chain/providers/locale_provider.dart';

final NotificationService notificationService = NotificationService();

Future<void> _initializeNotifications() async {
  await notificationService.init();
  await notificationService.scheduleSavedDailyReminder();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive();
  await Hive.openBox('settings');
  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);
  Intl.defaultLocale = 'tr_TR';
  runApp(const MyApp());
  // Initialize notifications without blocking UI
  // ignore: discarded_futures
  _initializeNotifications();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectProvider(notificationService: notificationService)),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ChainFlow Local',
            locale: localeProvider.locale,
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
