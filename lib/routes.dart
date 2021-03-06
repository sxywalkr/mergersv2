import 'package:flutter/material.dart';
import 'package:mergers/ui/auth/register_screen.dart';
import 'package:mergers/ui/auth/sign_in_screen.dart';
import 'package:mergers/ui/setting/setting_screen.dart';
import 'package:mergers/ui/splash/splash_screen.dart';
import 'package:mergers/ui/todo/create_edit_todo_screen.dart';
import 'package:mergers/ui/todo/todos_screen.dart';

import 'package:mergers/ui/home2/home2_screen.dart';
import 'package:mergers/ui/penyedia/penyedia_screen.dart';
import 'package:mergers/ui/penyedia/create_edit_penyedia_screen.dart';
import 'package:mergers/ui/personel/personel_screen.dart';
import 'package:mergers/ui/personel/create_edit_personel_screen.dart';
import 'package:mergers/ui/pengalaman/pengalaman_screen.dart';
import 'package:mergers/ui/pengalaman/create_edit_pengalaman_screen.dart';
import 'package:mergers/ui/peralatan/peralatan_screen.dart';
import 'package:mergers/ui/peralatan/create_edit_peralatan_screen.dart';
import 'package:mergers/ui/mergr_penyedia/mergr_penyedia_screen.dart';
import 'package:mergers/ui/mergr_penyedia/create_edit_mergr_penyedia_screen.dart';
import 'package:mergers/ui/mergr_peralatan/mergr_peralatan_screen.dart';
import 'package:mergers/ui/mergr_peralatan/create_edit_mergr_penyedia_peralatan_screen.dart';
import 'package:mergers/ui/mergr_personel/mergr_personel_screen.dart';
import 'package:mergers/ui/mergr_personel/create_edit_mergr_penyedia_personel_screen.dart';
import 'package:mergers/ui/referensi/referensi_screen.dart';
import 'package:mergers/ui/referensi/create_edit_referensi_screen.dart';
import 'package:mergers/ui/pekerjaan/pekerjaan_screen.dart';
import 'package:mergers/ui/pekerjaan/create_edit_pekerjaan_screen.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiate this object

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String setting = '/setting';
  static const String create_edit_todo = '/create_edit_todo';

  static const String home2 = '/home2';
  static const String penyedia = '/penyedia';
  static const String create_edit_penyedia = '/create_edit_penyedia';
  static const String personel = '/personel';
  static const String create_edit_personel = '/create_edit_personel';
  static const String pengalaman = '/pengalaman';
  static const String create_edit_pengalaman = '/create_edit_pengalaman';
  static const String peralatan = '/peralatan';
  static const String create_edit_peralatan = '/create_edit_peralatan';
  static const String mergr_penyedia = '/mergr_penyedia';
  static const String create_edit_mergr_penyedia =
      '/create_edit_mergr_penyedia';
  static const String mergr_peralatan = '/mergr_peralatan';
  static const String create_edit_mergr_penyedia_peralatan =
      '/create_edit_mergr_penyedia_peralatan';
  static const String mergr_personel = '/mergr_personel';
  static const String create_edit_mergr_penyedia_personel =
      '/create_edit_mergr_penyedia_personel';
  static const String referensi = '/referensi';
  static const String create_edit_referensi = '/create_edit_referensi';
  static const String pekerjaan = '/pekerjaan';
  static const String create_edit_pekerjaan = '/create_edit_pekerjaan';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => SignInScreen(),
    register: (BuildContext context) => RegisterScreen(),
    home: (BuildContext context) => TodosScreen(),
    setting: (BuildContext context) => SettingScreen(),
    create_edit_todo: (BuildContext context) => CreateEditTodoScreen(),
    home2: (BuildContext context) => Home2Screen(),
    penyedia: (BuildContext context) => PenyediaScreen(),
    create_edit_penyedia: (BuildContext context) => CreateEditPenyediaScreen(),
    personel: (BuildContext context) => PersonelScreen(),
    create_edit_personel: (BuildContext context) => CreateEditPersonelScreen(),
    pengalaman: (BuildContext context) => PengalamanScreen(),
    create_edit_pengalaman: (BuildContext context) =>
        CreateEditPengalamanScreen(),
    peralatan: (BuildContext context) => PeralatanScreen(),
    create_edit_peralatan: (BuildContext context) =>
        CreateEditPeralatanScreen(),
    mergr_penyedia: (BuildContext context) => MergrPenyediaScreen(),
    create_edit_mergr_penyedia: (BuildContext context) =>
        CreateEditMergrPenyediaScreen(),
    mergr_peralatan: (BuildContext context) => MergrPeralatanScreen(),
    create_edit_mergr_penyedia_peralatan: (BuildContext context) =>
        CreateEditMergrPenyediaPeralatanScreen(),
    mergr_personel: (BuildContext context) => MergrPersonelScreen(),
    create_edit_mergr_penyedia_personel: (BuildContext context) =>
        CreateEditMergrPenyediaPersonelScreen(),
    referensi: (BuildContext context) => ReferensiScreen(),
    create_edit_referensi: (BuildContext context) =>
        CreateEditReferensiScreen(),
    pekerjaan: (BuildContext context) => PekerjaanScreen(),
    create_edit_pekerjaan: (BuildContext context) =>
        CreateEditPekerjaanScreen(),
  };
}
