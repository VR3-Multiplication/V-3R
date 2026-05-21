import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/auth_providers.dart';
import '../providers/translation_providers.dart';
import 'adult_dashboard_screen.dart';

class AdultProfileSetupScreen extends ConsumerStatefulWidget {
  final bool isFirstSetup;

  const AdultProfileSetupScreen({super.key, this.isFirstSetup = false});

  @override
  ConsumerState<AdultProfileSetupScreen> createState() => _AdultProfileSetupScreenState();
}

class _AdultProfileSetupScreenState extends ConsumerState<AdultProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
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
          _displayNameController.text = profile.pseudo.startsWith('User_') ? '' : profile.pseudo;
          if (profile.fullName != null && profile.fullName!.contains(' ')) {
            final parts = profile.fullName!.split(' ');
            _firstNameController.text = parts.first;
            _lastNameController.text = parts.sublist(1).join(' ');
          } else {
            _firstNameController.text = profile.fullName ?? '';
            _lastNameController.text = '';
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
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

      final displayName = _displayNameController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = '$firstName $lastName'.trim();

      await client.from('profiles').update({
        'pseudo': displayName.isNotEmpty ? displayName : 'User_${userId.substring(0, 5)}',
        'full_name': fullName.isNotEmpty ? fullName : null,
      }).eq('id', userId);

      // Invalider le provider pour rafraîchir le profil utilisateur dans l'application
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.isFirstSetup) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdultDashboardScreen()),
          );
        } else {
          Navigator.pop(context);
        }
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

  void _skip() {
    if (widget.isFirstSetup) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdultDashboardScreen()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = ref.watch(currentUserProfileProvider).value?.role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFirstSetup ? 'Bienvenue !' : 'Mon Profil'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F7FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.teal.shade700,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.isFirstSetup ? 'Configurons votre profil' : 'Mettre à jour mon profil',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ces informations permettront à vos enfants ou élèves de savoir qui leur envoie des défis mathématiques.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 30),
                
                // Card de formulaire
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Champ Pseudo/Titre affiché à l'enfant
                        Text(
                          'Titre / Comment l\'enfant doit vous appeler',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            hintText: isTeacher ? 'Ex: M. Dupont, Maître...' : 'Ex: Papa, Maman, Tonton...',
                            prefixIcon: const Icon(Icons.face_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez saisir comment l\'enfant vous appelle';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Prénom
                        Text(
                          'Prénom (Optionnel)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            hintText: 'Votre prénom',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nom
                        Text(
                          'Nom (Optionnel)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            hintText: 'Votre nom de famille',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Boutons d'action
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                
                if (widget.isFirstSetup) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Passer pour le moment', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
