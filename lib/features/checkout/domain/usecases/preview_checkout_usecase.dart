import '../entities/checkout_preview.dart';
import '../repos/checkout_repo.dart';

class PreviewCheckoutUseCase {
  const PreviewCheckoutUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<CheckoutPreview> call() => _repo.getPreview();
}
