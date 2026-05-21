import 'user_profile.dart';

class AffiliatedChild {
  final UserProfile profile;
  final bool isSuperAdmin;
  final int sortOrder;

  AffiliatedChild({
    required this.profile,
    required this.isSuperAdmin,
    this.sortOrder = 0,
  });

  AffiliatedChild copyWith({
    UserProfile? profile,
    bool? isSuperAdmin,
    int? sortOrder,
  }) {
    return AffiliatedChild(
      profile: profile ?? this.profile,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AffiliatedChild &&
        other.profile == profile &&
        other.isSuperAdmin == isSuperAdmin &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => profile.hashCode ^ isSuperAdmin.hashCode ^ sortOrder.hashCode;
}
