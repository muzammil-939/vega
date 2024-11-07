// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vega/screens/home.dart';
import 'package:vega/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/firebase_auth.dart';

void main() async {
  // Ensure Flutter binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app after Firebase initialization
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, routes: {
      '/': (context) {
        return Consumer(
          builder: (context, ref, child) {
            print("build main.dart");
            final authState = ref.watch(phoneAuthProvider);

            // Check if the user has a valid refresh token
            if (authState.firebaseToken != null) {
              return HomePage(); // User is authenticated, redirect to Home
            } else {
              print('No valid refresh token, trying auto-login');
            }

            // Attempt auto-login if refresh token is not in state
            return FutureBuilder(
              future: ref.read(phoneAuthProvider.notifier).tryAutoLogin(),
              builder: (context, snapshot) {
                print(
                    'Token after auto-login attempt: ${ref.read(phoneAuthProvider).firebaseToken}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  ); // Show SplashScreen while waiting
                } else if (snapshot.hasData &&
                    snapshot.data == true &&
                    authState.firebaseToken != null) {
                  // If auto-login is successful and refresh token is available, go to Home
                  return HomePage();
                } else {
                  // If auto-login fails, redirect to login page
                  return LoginScreen();
                }
              },
            );
          },
        );
      },
    });
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
