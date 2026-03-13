import '../entities/pickup_point.dart';
import '../repos/checkout_repo.dart';

class GetPickupPointsUseCase {
  const GetPickupPointsUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<List<PickupPoint>> call({int? cityId}) =>
      _repo.getPickupPoints(cityId: cityId);
}
