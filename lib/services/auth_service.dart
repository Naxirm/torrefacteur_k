import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_torrefacteur_k/services/firestore_service.dart';
import 'package:new_torrefacteur_k/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get user => _auth.userChanges();

  Stream<AppUser?> get appUser async* {
    await for (final firebaseUser in _auth.userChanges()) {
      if (firebaseUser == null) {
        yield null;
      } else {
        final user =
            await _firestoreService.getUserFromFirestore(firebaseUser.uid);
        yield user;
      }
    }
  }

  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        return await _firestoreService.getUserFromFirestore(user.uid);
      }
      return null;
    } catch (e) {
      print('Erreur de connexion: $e');
      rethrow;
    }
  }

  Future<AppUser?> registerWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      print('Début de l\'inscription...');

      // 1. Création du compte Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Compte Auth créé: ${result.user?.uid}');

      final String userId = result.user!.uid;

      // 2. Création du document utilisateur dans Firestore
      print('Création du document utilisateur...');
      await _firestoreService.createUser(
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
      print('Document utilisateur créé');

      // 3. Récupération des données
      print('Récupération des données utilisateur...');
      final user = await _firestoreService.getUserFromFirestore(userId);

      if (user == null) {
        print('ERREUR: Utilisateur non trouvé après création');
        throw Exception('User document not found after creation');
      }

      print('Inscription réussie: ${user.email}');
      return user;
    } catch (e) {
      print('Erreur d\'inscription: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Optionnel : récupère l'utilisateur courant en tant que AppUser
  Future<AppUser?> getCurrentAppUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return await _firestoreService.getUserFromFirestore(currentUser.uid);
    }
    return null;
  }
}
