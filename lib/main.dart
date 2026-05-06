import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/purchases_page.dart';
import 'pages/debts_page.dart';
import 'pages/money_management_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/finance_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasUser = prefs.containsKey('userName');

  runApp(MyApp(hasUser: hasUser));
}

class MyApp extends StatelessWidget {
  final bool hasUser;
  const MyApp({super.key, required this.hasUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinanceCubit(),
      child: MaterialApp(
        title: 'تطبيق إدارة الأموال',
        theme: AppTheme.lightTheme,
        locale: const Locale('ar', 'SA'),
        home: hasUser ? const HomePage() : const LoginPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/purchases': (context) => const PurchasesPage(),
          '/debts': (context) => const DebtsPage(),
          '/money': (context) => const MoneyManagementPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
