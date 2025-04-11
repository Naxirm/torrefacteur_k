import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_torrefacteur_k/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  static const borderColor = Color(0xFFBC8B67);
  var isObscured = true;

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      if (_isLogin) {
        await auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await auth.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Image.asset(
                  'lib/assets/torrefacteur_logo.png',
                  height: 240,
                  width: 240,
                ),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      filled: true,
                      fillColor: const Color(0xFF4A2F24),
                      labelStyle: const TextStyle(color: borderColor),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 22.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: borderColor, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: borderColor, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: borderColor, width: 2.0),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Champ obligatoire' : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      filled: true,
                      fillColor: const Color(0xFF4A2F24),
                      labelStyle: const TextStyle(color: borderColor),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 22.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: borderColor, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: borderColor, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: borderColor, width: 2.0),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Champ obligatoire' : null,
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFF4A2F24),
                    labelStyle: const TextStyle(color: borderColor),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 22.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: borderColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: borderColor, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: borderColor, width: 2.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Champ obligatoire' : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        color: borderColor,
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                        icon: isObscured
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility)),
                    labelText: 'Mot de passe',
                    filled: true,
                    fillColor: const Color(0xFF4A2F24),
                    labelStyle: const TextStyle(color: borderColor),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 22.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: borderColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: borderColor, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: borderColor, width: 2.0),
                    ),
                  ),
                  obscureText: isObscured,
                  validator: (value) =>
                      value!.isEmpty ? 'Champ obligatoire' : null,
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6B17E),
                          foregroundColor: const Color(0xFF2C1810),
                          padding: const EdgeInsets.symmetric(
                              vertical: 22.0, horizontal: 10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      child: Text(_isLogin ? 'Se connecter' : "S'inscrire"),
                    ),
                  ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin
                      ? 'Créer un compte'
                      : 'Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
