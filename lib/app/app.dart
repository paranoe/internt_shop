import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:diplomeprojectmobile/app/di/providers.dart';
import 'package:diplomeprojectmobile/app/router/app_router.dart';
import 'package:diplomeprojectmobile/app/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Builder(
        builder: (context) {
          final router = AppRouter.create(context);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
