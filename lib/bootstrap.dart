import 'package:flutter/material.dart';
import 'package:diplomeprojectmobile/app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
