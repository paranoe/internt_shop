import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/profile/data/datasources/profile_api.dart';
import 'package:diplomeprojectmobile/features/profile/data/repos/profile_repo_impl.dart';
import 'package:diplomeprojectmobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:diplomeprojectmobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/controllers/profile_state.dart';

class ProfileController extends Cubit<ProfileState> {
  ProfileController({required ProfileApi profileApi})
    : _profileApi = profileApi,
      _getProfileUseCase = GetProfileUseCase(ProfileRepoImpl(profileApi)),
      _updateProfileUseCase = UpdateProfileUseCase(ProfileRepoImpl(profileApi)),
      super(const ProfileState());

  final ProfileApi _profileApi;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    try {
      final profile = await _getProfileUseCase();
      final cards = await _profileApi.getCards();
      final pickupPoints = await _profileApi.getPickupPoints();

      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
          cards: cards,
          pickupPoints: pickupPoints,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? patronymic,
    String? phone,
    String? gender,
  }) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearError: true));

    try {
      final profile = await _updateProfileUseCase(
        firstName: firstName,
        lastName: lastName,
        patronymic: patronymic,
        phone: phone,
        gender: gender,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> addCard(String cardNumber) async {
    try {
      await _profileApi.addCard(cardNumber);
      await loadProfile();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> deleteCard(int cardId) async {
    try {
      await _profileApi.deleteCard(cardId);
      await loadProfile();
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> addPickupPoint(int pickupPointId) async {
    try {
      await _profileApi.addPickupPoint(pickupPointId);
      await loadProfile();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> deletePickupPoint(int userPickupId) async {
    try {
      await _profileApi.deletePickupPoint(userPickupId);
      await loadProfile();
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCities() async {
    return _profileApi.getCities();
  }

  Future<List<Map<String, dynamic>>> getPickupPointsByCity(int cityId) async {
    return _profileApi.getPickupPointsByCity(cityId);
  }
}
