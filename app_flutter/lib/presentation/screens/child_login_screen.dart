import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/translation_providers.dart';
import 'child_dashboard_screen.dart';

import '../providers/session_tracker.dart';

class ChildLoginScreen extends ConsumerStatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  ConsumerState<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends ConsumerState<ChildLoginScreen> {
  final _pseudoController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePin = true;

  Future<void> _authenticate() async {
    final pseudo = _pseudoController.text.trim();
    final pin = _pinController.text.trim();
    
    if (pseudo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(ref, 'pseudo_empty'))),
      );
      return;
    }

    if (pin.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(ref, 'pin_too_short'))),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        final useCase = ref.read(loginChildUseCaseProvider);
        await useCase.execute(pseudo: pseudo, pin: pin);
      } else {
        final useCase = ref.read(registerChildUseCaseProvider);
        await useCase.execute(pseudo: pseudo, pin: pin);
      }
      
      // Mettre à jour la date de dernière activité
      await SessionTracker.updateActivity();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChildDashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        String message = e.toString().replaceAll('Exception: ', '');
        if (message.contains('invalid_credentials') || message.contains('Invalid login credentials')) {
          message = "Ce pseudo n'existe pas ou le code secret est incorrect.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade600,
              Colors.teal.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.face,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isLogin ? tr(ref, 'bon_retour') : tr(ref, 'creer_profil'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Formulaire Enfant
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _pseudoController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: tr(ref, 'mon_pseudo'),
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                         TextField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (_) => setState(() {}), // Force rebuild pour le bouton
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: tr(ref, 'mon_code_secret'),
                            helperText: tr(ref, 'pin_helper'),
                            helperStyle: TextStyle(
                              color: _pinController.text.length >= 6 ? Colors.green : Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscurePin = !_obscurePin;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: (_isLoading || _pinController.text.length < 6) ? null : _authenticate,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    _isLogin ? 'Jouer !' : 'C\'est parti !',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Je n\'ai pas de profil, j\'en crée un !'
                                : 'J\'ai déjà un profil, je me connecte !',
                            style: TextStyle(color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
