import 'package:equatable/equatable.dart';

import 'package:diplomeprojectmobile/features/profile/domain/entities/profile.dart';

enum ProfileStatus { initial, loading, success, saving, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.cards = const [],
    this.pickupPoints = const [],
    this.errorMessage,
  });

  final ProfileStatus status;
  final ProfileEntity? profile;
  final List<Map<String, dynamic>> cards;
  final List<Map<String, dynamic>> pickupPoints;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    List<Map<String, dynamic>>? cards,
    List<Map<String, dynamic>>? pickupPoints,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      cards: cards ?? this.cards,
      pickupPoints: pickupPoints ?? this.pickupPoints,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    cards,
    pickupPoints,
    errorMessage,
  ];
}
