import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart'; // Pour récupérer supabaseClientProvider
import '../../data/datasources/affiliation_remote_data_source.dart';
import '../../data/repositories/affiliation_repository_impl.dart';
import '../../domain/repositories/affiliation_repository.dart';
import '../../domain/usecases/affiliate_child_usecase.dart';
import '../../domain/usecases/get_affiliated_children_usecase.dart';
import '../../domain/usecases/revoke_affiliation_usecase.dart';
import '../../domain/usecases/get_child_affiliates_usecase.dart';
import '../../domain/entities/affiliated_child.dart';
import '../../domain/entities/affiliate_adult.dart';

// 1. Data Source
final affiliationRemoteDataSourceProvider = Provider<AffiliationRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AffiliationRemoteDataSourceImpl(supabaseClient: client);
});

// 2. Repository
final affiliationRepositoryProvider = Provider<AffiliationRepository>((ref) {
  final dataSource = ref.watch(affiliationRemoteDataSourceProvider);
  return AffiliationRepositoryImpl(remoteDataSource: dataSource);
});

// 3. UseCases
final affiliateChildUseCaseProvider = Provider<AffiliateChildUseCase>((ref) {
  final repository = ref.watch(affiliationRepositoryProvider);
  return AffiliateChildUseCase(repository);
});

final getAffiliatedChildrenUseCaseProvider = Provider<GetAffiliatedChildrenUseCase>((ref) {
  final repository = ref.watch(affiliationRepositoryProvider);
  return GetAffiliatedChildrenUseCase(repository);
});

final revokeAffiliationUseCaseProvider = Provider<RevokeAffiliationUseCase>((ref) {
  final repository = ref.watch(affiliationRepositoryProvider);
  return RevokeAffiliationUseCase(repository);
});

final getChildAffiliatesUseCaseProvider = Provider<GetChildAffiliatesUseCase>((ref) {
  final repository = ref.watch(affiliationRepositoryProvider);
  return GetChildAffiliatesUseCase(repository);
});

// 4. State / UI Providers
final affiliatedChildrenProvider = FutureProvider.autoDispose<List<AffiliatedChild>>((ref) async {
  final useCase = ref.watch(getAffiliatedChildrenUseCaseProvider);
  return await useCase.execute();
});

final childAffiliatesProvider = FutureProvider.family.autoDispose<List<AffiliateAdult>, String>((ref, childId) async {
  final useCase = ref.watch(getChildAffiliatesUseCaseProvider);
  return await useCase.execute(childId);
});

class StudentSortPreferenceNotifier extends StateNotifier<AsyncValue<String>> {
  final AffiliationRepository _repository;

  StudentSortPreferenceNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPreference();
  }

  Future<void> loadPreference() async {
    try {
      final pref = await _repository.getStudentSortPreference();
      state = AsyncValue.data(pref);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePreference(String preference) async {
    state = AsyncValue.data(preference);
    try {
      await _repository.updateStudentSortPreference(preference);
    } catch (e) {
      loadPreference();
    }
  }
}

final studentSortPreferenceProvider = StateNotifierProvider.autoDispose<StudentSortPreferenceNotifier, AsyncValue<String>>((ref) {
  final repo = ref.watch(affiliationRepositoryProvider);
  return StudentSortPreferenceNotifier(repo);
});

class DashboardSelectionState {
  final bool isSelectionMode;
  final Set<String> selectedChildIds;

  DashboardSelectionState({
    this.isSelectionMode = false,
    required this.selectedChildIds,
  });

  DashboardSelectionState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedChildIds,
  }) {
    return DashboardSelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedChildIds: selectedChildIds ?? this.selectedChildIds,
    );
  }
}

class DashboardSelectionNotifier extends StateNotifier<DashboardSelectionState> {
  DashboardSelectionNotifier() : super(DashboardSelectionState(selectedChildIds: {}));

  void enterSelectionMode() {
    state = state.copyWith(isSelectionMode: true);
  }

  void exitSelectionMode() {
    state = DashboardSelectionState(selectedChildIds: {});
  }

  void toggleSelection(String childId) {
    final updated = Set<String>.from(state.selectedChildIds);
    if (updated.contains(childId)) {
      updated.remove(childId);
    } else {
      updated.add(childId);
    }
    state = state.copyWith(selectedChildIds: updated);
  }

  void selectAll(List<String> childIds) {
    state = state.copyWith(selectedChildIds: Set<String>.from(childIds));
  }

  void clearSelection() {
    state = state.copyWith(selectedChildIds: {});
  }
}

final dashboardSelectionProvider = StateNotifierProvider.autoDispose<DashboardSelectionNotifier, DashboardSelectionState>((ref) {
  return DashboardSelectionNotifier();
});

