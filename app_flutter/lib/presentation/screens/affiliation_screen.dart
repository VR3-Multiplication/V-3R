import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/affiliation_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/translation_providers.dart';

class AffiliationScreen extends ConsumerStatefulWidget {
  const AffiliationScreen({super.key});

  @override
  ConsumerState<AffiliationScreen> createState() => _AffiliationScreenState();
}

class _AffiliationScreenState extends ConsumerState<AffiliationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le code doit contenir exactement 6 caractères.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final useCase = ref.read(affiliateChildUseCaseProvider);
      await useCase.execute(affiliationCode: code);

      if (mounted) {
        final currentUser = ref.read(supabaseClientProvider).auth.currentUser;
        final isTeacher = currentUser?.userMetadata?['role'] == 'teacher';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isTeacher
                ? 'Succès ! L\'élève a été ajouté à votre tableau de bord.'
                : 'Succès ! L\'enfant a été ajouté à votre tableau de bord.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Retour au tableau de bord
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
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
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(supabaseClientProvider).auth.currentUser;
    final isTeacher = currentUser?.userMetadata?['role'] == 'teacher';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? tr(ref, 'affiliate_student') : tr(ref, 'affiliate_child')),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.link,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Entrez le code secret',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isTeacher ? tr(ref, 'ask_student_code') : tr(ref, 'ask_child_code'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Encadré d'explication élégant
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.shade200.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.orange.shade300, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Où trouver ce code ?',
                              style: TextStyle(
                                color: Colors.orange.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isTeacher
                                  ? '1. Ouvrez l\'application de l\'élève.\n2. Allez dans son Profil (icône 👤 en haut à droite).\n3. Copiez le code affiché dans l\'encadré bleu.'
                                  : '1. Ouvrez l\'application de l\'enfant.\n2. Allez dans son Profil (icône 👤 en haut à droite).\n3. Copiez le code affiché dans l\'encadré bleu.',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                TextField(
                  controller: _codeController,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    UpperCaseTextFormatter(), // Un custom formatter pour forcer les majuscules
                  ],
                  decoration: InputDecoration(
                    labelText: 'Code d\'affiliation (ex: A1B2C3)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitCode,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Valider le code',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Utilitaire pour forcer les majuscules pendant la saisie
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
