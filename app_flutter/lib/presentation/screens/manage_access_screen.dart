import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/affiliation_providers.dart';
import '../providers/auth_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/affiliate_adult.dart';

class ManageAccessScreen extends ConsumerWidget {
  final UserProfile child;
  final bool isUserSuperAdmin;

  const ManageAccessScreen({
    super.key,
    required this.child,
    required this.isUserSuperAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affiliatesAsync = ref.watch(childAffiliatesProvider(child.id));
    final currentUser = ref.watch(supabaseClientProvider).auth.currentUser;
    final currentUserId = currentUser?.id;
    final isTeacher = currentUser?.userMetadata?['role'] == 'teacher';
    final childName = (child.fullName != null && child.fullName!.trim().isNotEmpty)
        ? (isTeacher ? child.fullName! : child.fullName!.trim().split(' ').first)
        : child.pseudo;

    return Scaffold(
      appBar: AppBar(
        title: Text('Accès : $childName'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: affiliatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (affiliates) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: affiliates.length,
            itemBuilder: (context, index) {
              final affiliate = affiliates[index];
              final bool isMe = affiliate.id == currentUserId;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: affiliate.isSuperAdmin ? Colors.amber.shade100 : Colors.grey.shade200,
                    child: Icon(
                      affiliate.isSuperAdmin ? Icons.workspace_premium : Icons.person,
                      color: affiliate.isSuperAdmin ? Colors.amber.shade800 : Colors.grey,
                    ),
                  ),
                  title: Text(
                    isMe ? '${affiliate.pseudo} (Moi)' : affiliate.pseudo,
                    style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
                  ),
                  subtitle: Text(affiliate.isSuperAdmin ? 'Responsable (Super-Admin)' : 'Consultant / Enseignant'),
                  trailing: _buildTrailing(context, ref, affiliate, isMe, isTeacher),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget? _buildTrailing(BuildContext context, WidgetRef ref, AffiliateAdult affiliate, bool isMe, bool isTeacher) {
    // Règle : 
    // 1. On peut toujours se retirer soi-même (bouton "Se désaffilier" / "Désaffilier")
    // 2. Un Super-Admin peut retirer n'importe qui SAUF un autre Super-Admin (pour éviter les blocages)
    
    if (isMe) {
      return TextButton.icon(
        onPressed: () => _handleRevoke(context, ref, affiliate, true, isTeacher),
        icon: const Icon(Icons.person_remove_outlined, color: Colors.orange),
        label: Text(isTeacher ? 'Désaffilier' : 'Se désaffilier', style: const TextStyle(color: Colors.orange)),
      );
    }

    if (isUserSuperAdmin && !affiliate.isSuperAdmin) {
      return IconButton(
        icon: const Icon(Icons.person_remove, color: Colors.red),
        onPressed: () => _handleRevoke(context, ref, affiliate, false, isTeacher),
      );
    }

    return null;
  }

  void _handleRevoke(BuildContext context, WidgetRef ref, AffiliateAdult affiliate, bool isSelf, bool isTeacher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSelf 
          ? (isTeacher ? 'Désaffilier cet élève ?' : 'Se désaffilier de cet enfant ?')
          : 'Révoquer l\'accès ?'),
        content: Text(
          isSelf 
            ? (isTeacher
              ? 'Voulez-vous vraiment désaffilier ${(child.fullName != null && child.fullName!.trim().isNotEmpty) ? child.fullName! : child.pseudo} ? Il n\'apparaîtra plus sur votre tableau de bord.'
              : 'Voulez-vous vraiment ne plus être lié à ${(child.fullName != null && child.fullName!.trim().isNotEmpty) ? child.fullName! : child.pseudo} ?')
            : 'Voulez-vous retirer l\'accès à ${affiliate.pseudo} pour l\'enfant ${(child.fullName != null && child.fullName!.trim().isNotEmpty) ? child.fullName! : child.pseudo} ?'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text(isSelf 
              ? (isTeacher ? 'Désaffilier' : 'Se désaffilier')
              : 'Révoquer', style: const TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(revokeAffiliationUseCaseProvider).execute(
          adultId: affiliate.id,
          childId: child.id,
        );
        
        if (isSelf) {
          // Si on s'est retiré soi-même, on rentre au dashboard
          if (context.mounted) {
            Navigator.pop(context); // Ferme l'écran de gestion
            ref.invalidate(affiliatedChildrenProvider);
          }
        } else {
          // Sinon on rafraîchit juste la liste des collaborateurs
          ref.invalidate(childAffiliatesProvider(child.id));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }
}
