import '../entities/city.dart';
import '../repos/checkout_repo.dart';

class GetCitiesUseCase {
  const GetCitiesUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<List<City>> call() => _repo.getCities();
}
