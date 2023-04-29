import 'package:bloc_tutorial_example/store/repository/store_repository.dart';
import 'package:bloc_tutorial_example/store/store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StoreBloc() : super(StoreState()) {
    on<StoreProductsRequested>(_handleStoreProductRequest);
    on<StoreProductsAddedToCart>(_handleStoreProductsAddToCart);
    on<StoreProductsRemovedFromCart>(_handleStoreProductsRemoveFromCart);
  }

  final StoreRepository api = StoreRepository();

  Future<void> _handleStoreProductRequest(
    StoreProductsRequested event,
    Emitter<StoreState> emit,
  ) async {
    try {
      emit(state.copyWith(
        productsStatus: StoreRequest.requestInProgress,
      ));

      final response = await api.getProducts();
      emit(state.copyWith(
        productsStatus: StoreRequest.requestSuccess,
        products: response,
      ));
    } catch (e) {
      emit(state.copyWith(productsStatus: StoreRequest.requestFailure));
    }
  }

  Future<void> _handleStoreProductsAddToCart(
      StoreProductsAddedToCart event, Emitter<StoreState> emit) async {
    emit(state.copyWith(cartIds: {...state.cartIds, event.cartId}));
  }

  Future<void> _handleStoreProductsRemoveFromCart(
      StoreProductsRemovedFromCart event, Emitter<StoreState> emit) async {
    emit(state.copyWith(cartIds: {...state.cartIds}..remove(event.cartId)));
  }
}
