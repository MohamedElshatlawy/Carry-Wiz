import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:toast/toast.dart';
import '../components/default-app-bar-widget.dart';
import '../injector/injector.dart';
import '../main.dart';
import '../screens/change-property-screen.dart';
import '../services/ApiAuthProvider.dart';
import '../themes/DarkThemeProvider.dart';
import '../themes/palette.dart';
import '../utilities/SharedPreferencesManager.dart';
import '../localization/language.dart';
import '../localization/language_constants.dart';

import '../utilities/globals.dart' as globals;

void main() {
  runApp(
    MaterialApp(
      title: 'Settings screen',
      home: SettingsScreen(),
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;
  bool darkMode = false;
  bool _apiUser = false;
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();

  void _changeLanguage(Language language) async {
    print(language.name);
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  @override
  void initState() {
    super.initState();
    darkMode =
        _sharedPreferencesManager.getBool(SharedPreferencesManager.keyDarkMode)!;
    _apiUser =
        _sharedPreferencesManager.getBool(SharedPreferencesManager.keyApiUser)!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: DefaultAppBar(
          title: getTranslatedValues(context, 'settings'),
        ),
        body: SettingsList(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey
              : Palette.lightPurple,
          sections: [
            SettingsSection(
              title: getTranslatedValues(context, 'common'),
              tiles: [
                SettingsTile(
                  title: getTranslatedValues(context, 'change_language'),
                  leading: Icon(
                    Icons.language,
                    size: ScreenUtil().setSp(45),
                  ),
                  trailing: DropdownButton<Language>(
                    underline: SizedBox(),
                    // icon: Icon(
                    //   Icons.language,
                    //   color: Colors.white,
                    // ),
                    hint: Text(getTranslatedValues(context, 'language')),
                    onChanged: (Language? language) =>
                        _changeLanguage(language!),
                    items: Language.languageList()
                        .map<DropdownMenuItem<Language>>(
                          (e) => DropdownMenuItem<Language>(
                            value: e,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  e.flag,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60)),
                                ),
                                Text(e.name)
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onTap: () {},
                  ),
                ),
                SettingsTile.switchTile(
                  title: getTranslatedValues(context, 'dark_mode'),
                  leading: Icon(
                    Icons.lightbulb_outline,
                    size: ScreenUtil().setSp(45),
                  ),
                  switchValue: darkMode,
                  onToggle: (bool value) {
                    setState(() {
                      darkMode = value;
                      Provider.of<DarkThemeProvider>(context, listen: false)
                          .darkTheme = value;
                    });
                  },
                ),
              ],
            ),
            if (!_apiUser)
              SettingsSection(
                title: getTranslatedValues(context, 'security'),
                tiles: [
//                SettingsTile.switchTile(
//                  title: 'Lock app in background',
//                  leading: Icon(Icons.phonelink_lock),
//                  switchValue: lockInBackground,
//                  onToggle: (bool value) {
//                    setState(() {
//                      lockInBackground = value;
//                    });
//                  },
//                ),
//                SettingsTile.switchTile(
//                    title: 'Use fingerprint',
//                    leading: Icon(Icons.fingerprint),
//                    onToggle: (bool value) {},
//                    switchValue: false),

                  SettingsTile(
                    title: getTranslatedValues(context, 'change_password'),
                    leading: Icon(
                      Icons.lock,
                      size: ScreenUtil().setSp(45),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeProperty(
                          changedProperty: 'Password',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SettingsSection(
              title: getTranslatedValues(context, 'account'),
              tiles: [
                if (!_apiUser)
                  SettingsTile(
                    title: getTranslatedValues(context, 'change_email'),
                    leading: Icon(
                      Icons.email,
                      size: ScreenUtil().setSp(45),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChangeProperty(
                                changedProperty: 'Email',
                              )),
                    ),
                  ),
                SettingsTile(
                  title: getTranslatedValues(context, 'sign_out'),
                  leading: Icon(
                    Icons.exit_to_app,
                    size: ScreenUtil().setSp(45),
                  ),
                  onTap: (() async {
                    globals.googleSignIn.isSignedIn().then((s) {
                      s ? globals.googleSignIn.signOut() : null;
                    });
                    globals.facebookLogin.isLoggedIn.then((b) {
                      b ? globals.facebookLogin.logOut() : null;
                    });
                    _sharedPreferencesManager.clearAll();
                    Toast.show("signed out", context,
                        duration: Toast.lengthLong, gravity: Toast.bottom);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login_screen', (_) => false);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
