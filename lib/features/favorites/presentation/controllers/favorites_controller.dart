import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplomeprojectmobile/core/utils/error_mapper.dart';
import 'package:diplomeprojectmobile/features/favorites/data/datasources/favorites_api.dart';
import 'favorites_state.dart';

class FavoritesController extends Cubit<FavoritesState> {
  FavoritesController({required FavoritesApi favoritesApi})
    : _favoritesApi = favoritesApi,
      super(const FavoritesState());

  final FavoritesApi _favoritesApi;

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading, clearError: true));

    try {
      final items = await _favoritesApi.getFavorites();

      emit(
        state.copyWith(
          status: FavoritesStatus.success,
          items: items,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> addFavorite(int productId) async {
    try {
      await _favoritesApi.addFavorite(productId);
      await loadFavorites();
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> removeFavorite(int productId) async {
    try {
      await _favoritesApi.deleteFavorite(productId);
      await loadFavorites();
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  bool isFavorite(int productId) {
    return state.items.any((item) => item.productId == productId);
  }

  Future<void> toggleFavorite(int productId) async {
    if (isFavorite(productId)) {
      await removeFavorite(productId);
    } else {
      await addFavorite(productId);
    }
  }
}
