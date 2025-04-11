import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';
import 'package:new_torrefacteur_k/screens/auth_screen.dart';
import 'package:new_torrefacteur_k/screens/home_screen.dart';
import 'package:new_torrefacteur_k/services/auth_service.dart';
import 'package:new_torrefacteur_k/services/firestore_service.dart';
import 'package:new_torrefacteur_k/services/data_init_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DataInitService().initializeAllData();

  // fonction permettant aux boutons d'actions du téléphone d'avoir un background marron
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF2C1810),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        StreamProvider<AppUser?>(
          create: (context) => context.read<AuthService>().appUser,
          initialData: null,
        ),
      ],
      child: const TorrefacteurKApp(),
    ),
  );
}

class TorrefacteurKApp extends StatelessWidget {
  const TorrefacteurKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Torréfacteur K',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF2C1810),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: const Color(0xFFE6B17E),
              displayColor: const Color(0xFFE6B17E),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A2F24),
          titleTextStyle: TextStyle(
            color: Color(0xFFE6B17E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erreur: ${snapshot.error}')),
          );
        }

        final user = snapshot.data;
        return user == null ? const AuthScreen() : const HomeScreen();
      },
    );
  }
}
