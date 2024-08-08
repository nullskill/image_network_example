import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_network_example/model/product.dart';
import 'package:image_network_example/repository/product_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository _repository;

  ProductsBloc({required ProductRepository repository})
      : _repository = repository,
        super(ProductsLoading()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductsState> emit) async {
    try {
      final products = await _repository.fetchProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(const ProductsError('Error loading products'));
    }
  }
}
