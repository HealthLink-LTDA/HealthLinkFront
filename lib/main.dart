import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medical_app/providers/auth_provider.dart';
import 'package:medical_app/providers/patient_provider.dart';
import 'package:medical_app/providers/user_provider.dart';
import 'package:medical_app/providers/record_provider.dart';
import 'package:medical_app/screens/login_screen.dart';
import 'package:medical_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PatientProvider>(
          create: (context) => PatientProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, authProvider, previousPatientProvider) =>PatientProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, authProvider, previousUserProvider) =>UserProvider(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RecordProvider>(
          create: (context) => RecordProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, authProvider, previousRecordProvider) =>RecordProvider(authProvider),
        ),

      ],
      child: MaterialApp(
        title: 'Medical App',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}