import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'views/auth_view.dart';
import 'views/dashboard_view.dart';
import 'views/analysis_view.dart';
import 'viewmodels/dashboard_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Controle Financeiro",
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthView(),
          '/dashboard': (context) => const DashboardView(),
          '/analysis': (context) => const AnalysisView(),
        },
      ),
    );
  }
}