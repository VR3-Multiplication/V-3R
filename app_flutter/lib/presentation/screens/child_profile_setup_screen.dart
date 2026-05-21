import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class ChildProfileSetupScreen extends ConsumerStatefulWidget {
  const ChildProfileSetupScreen({super.key});

  @override
  ConsumerState<ChildProfileSetupScreen> createState() => _ChildProfileSetupScreenState();
}

class _ChildProfileSetupScreenState extends ConsumerState<ChildProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pseudoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameInitialController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profile = await ref.read(currentUserProfileProvider.future);
      if (profile != null && mounted) {
        setState(() {
          _pseudoController.text = profile.pseudo;
          if (profile.fullName != null && profile.fullName!.isNotEmpty) {
            final parts = profile.fullName!.trim().split(' ');
            _firstNameController.text = parts.first;
            if (parts.length > 1) {
              // Récupérer la première lettre de l'initiale s'il y en a une (ex: "B." -> "B")
              final initial = parts.last.replaceAll('.', '');
              _lastNameInitialController.text = initial;
            }
          }
        });
      }
    } catch (e) {
      // Ignorer
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
    _firstNameController.dispose();
    _lastNameInitialController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;

      if (userId == null) throw Exception("Utilisateur non connecté.");

      final pseudo = _pseudoController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastNameInitial = _lastNameInitialController.text.trim();

      // Construction du nom complet de manière conforme au RGPD (Lucas B. ou juste Lucas)
      final fullName = lastNameInitial.isNotEmpty
          ? '$firstName ${lastNameInitial.toUpperCase()}.'
          : firstName;

      await client.from('profiles').update({
        'pseudo': pseudo,
        'full_name': fullName.isNotEmpty ? fullName : null,
      }).eq('id', userId);

      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Profil mis à jour avec succès !'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde : $e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF0F4F8),
        width: double.infinity,
        height: double.infinity,
        child: _isLoading && _pseudoController.text.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.face_rounded,
                          size: 90,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Message de conformité RGPD / Protection des données
                      Card(
                        elevation: 0,
                        color: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.security, color: Color(0xFF1976D2), size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Protection de ta vie privée (RGPD)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D47A1),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Pour ta sécurité, n'écris jamais ton nom de famille complet. Utilise ton prénom et seulement la première lettre de ton nom pour que ton enseignant ou parent te reconnaisse.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade900,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pseudo
                              const Text(
                                'Ton Pseudo de joueur',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _pseudoController,
                                decoration: InputDecoration(
                                  hintText: 'Ex: SuperLapin77',
                                  prefixIcon: const Icon(Icons.videogame_asset_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Choisis un pseudo !';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Prénom
                              const Text(
                                'Ton Prénom',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  hintText: 'Ex: Lucas',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Écris ton prénom !';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Initiale du nom
                              const Text(
                                'Initiale de ton Nom (Optionnel)',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _lastNameInitialController,
                                maxLength: 1,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: 'Ex: D',
                                  prefixIcon: const Icon(Icons.abc_rounded),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                  counterText: '', // masque le compteur de caractères
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Enregistrer',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
