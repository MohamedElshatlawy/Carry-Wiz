import 'dart:io';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:Carrywiz/localization/AppLocalizations.dart';
import 'screens/login_screen.dart';
import 'screens/my-home-page.dart';
import 'services/MyHttpOverrides.dart';
import 'themes/DarkThemeProvider.dart';
import 'themes/themes.dart';
// import 'package:new_version/new_version.dart';
import 'utilities/SharedPreferencesManager.dart';
import 'package:Carrywiz/localization/language_constants.dart';
import 'package:Carrywiz/injector/injector.dart';
import 'package:Carrywiz/provider/KilosCounterProvider.dart';
import 'package:Carrywiz/provider/AppLanguage.dart';
import 'package:Carrywiz/screens/package-requests-screen.dart';
import 'package:Carrywiz/screens/settings-screen.dart';
import 'package:Carrywiz/services/data_connectivity_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await EasyLocalization.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp();

  await setupLocator();
  getCurrentAppTheme();

  services.SystemChrome.setPreferredOrientations([
    services.DeviceOrientation.portraitUp,
    services.DeviceOrientation.portraitDown
  ]).then((_) {
    runApp(MyApp()
        // DevicePreview(
        //   enabled: false,
        //   // enabled: !kReleaseMode,
        //   builder: (context) => MyApp(),
        // ),
        );
  });
}

void getCurrentAppTheme() async {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  themeChangeProvider.darkTheme =
      (await themeChangeProvider.darkThemePreference.getTheme())!;
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    _getLocale().then((value) => _locale = value);
    super.initState();
  }

  Locale _locale = Locale('US');

  late AppLanguage appLanguage;

  Future<Locale> _getAppLanguage() async {
    AppLanguage appLanguage = AppLanguage();
    return await appLanguage.fetchLocale();
  }

  Future<Locale> _getLocale() async {
    await _getAppLanguage().then((value) => _locale = value);
    return _locale;
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print('LANG ${_locale.countryCode}');
    bool _isAlreadyLoggedIn;
    if (_sharedPreferencesManager
        .isKeyExists(SharedPreferencesManager.keyIsLogin)) {
      _isAlreadyLoggedIn = _sharedPreferencesManager
          .getBool(SharedPreferencesManager.keyIsLogin)!;
    } else {
      _isAlreadyLoggedIn = false;
    }
    return StreamProvider<InternetConnectionStatus>(
      initialData: InternetConnectionStatus.connected,
      create: (_) =>
          DataConnectivityService().connectivityStreamController.stream,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<KilosCounterProvider>(
              create: (_) => KilosCounterProvider()),
          ChangeNotifierProvider<DarkThemeProvider>(
              create: (_) => DarkThemeProvider()),
          ChangeNotifierProvider<AppLanguage>(create: (_) => appLanguage),
        ],
        child: Consumer(
          builder: (BuildContext context, DarkThemeProvider darkThemeProvider,
              Widget? child) {
            var locale2 = _locale;
            return MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                // Built-in localization of basic text for Material widgets
                GlobalMaterialLocalizations.delegate,
                // Built-in localization for text direction LTR/RTL
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // List all of the app's supported locales here
              supportedLocales: [
                Locale(ENGLISH_CODE, ENGLISH_COUNTRY_CODE),
                Locale(ARABIC_CODE, ARABIC_COUNTRY_CODE),
              ],
              locale: locale2,

              // These delegates make sure that the localization data for the proper language is loaded
              // Returns a locale which will be used by the app
              localeResolutionCallback: (locale, supportedLocales) {
                // Check if the current device locale is supported
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode ||
                      supportedLocale.countryCode == locale?.countryCode) {
                    return supportedLocale;
                  }
                }
                // If the locale of the device is not supported, use the first one
                // from the list (English, in this case).
                return supportedLocales.first;
              },
              // builder: DevicePreview.appBuilder, // <--- /!\ Add the builder
              title: 'Carrywiz',
              theme: Styles.themeData(darkThemeProvider.darkTheme, context),
              debugShowCheckedModeBanner: false,
              home: _isAlreadyLoggedIn ? MyHomePage(0) : UserLogin(),
              routes: <String, WidgetBuilder>{
                '/home_screen': (context) => MyHomePage(0),
                '/login_screen': (context) => UserLogin(),
                '/settings_screen': (context) => SettingsScreen(),
                '/package_requests_screen': (context) =>
                    PackageRequestsScreen(),
              },
              onUnknownRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (BuildContext context) =>
                      Scaffold(body: Center(child: Text('Page not found'))),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
