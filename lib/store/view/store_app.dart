import 'package:flutter/material.dart';
import 'package:bloc_tutorial_example/store/store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_screen.dart';

class StoreApp extends StatelessWidget {
  const StoreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: BlocProvider(
        create: (context) => StoreBloc(),
        child: const _StoreAppView(title: 'My Store'),
      ),
    );
  }
}

class _StoreAppView extends StatefulWidget {
  const _StoreAppView({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<_StoreAppView> createState() => _StoreAppViewState();
}

class _StoreAppViewState extends State<_StoreAppView> {
  void _addToCart(int cartId) {
    context.read<StoreBloc>().add(StoreProductsAddedToCart(cartId));
  }

  void _removeFromCart(int cartId) {
    context.read<StoreBloc>().add(StoreProductsRemovedFromCart(cartId));
  }

  void _viewCart(){
    Navigator.push(
      context,
      PageRouteBuilder(
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: BlocProvider.value(
                value: context.read<StoreBloc>(),
                child: child,
              ),
            );
          },
          pageBuilder: (_, __, ___) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: BlocBuilder<StoreBloc, StoreState>(
          builder: (context, state) {
            if (state.productsStatus == StoreRequest.requestInProgress) {
              return const CircularProgressIndicator();
            }

            if (state.productsStatus == StoreRequest.requestFailure) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Problem loading products"),
                  const SizedBox(
                    height: 10,
                  ),
                  OutlinedButton(
                      onPressed: () {
                        context.read<StoreBloc>().add(StoreProductsRequested());
                      },
                      child: Text("Try again"))
                ],
              );
            }

            if (state.productsStatus == StoreRequest.unknown) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shop_2_outlined,
                    size: 60,
                    color: Colors.black26,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("No products to view"),
                  const SizedBox(
                    height: 10,
                  ),
                  OutlinedButton(
                      onPressed: () {
                        context.read<StoreBloc>().add(StoreProductsRequested());
                      },
                      child: const Text("Load products"))
                ],
              );
            }
            return GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: state.products.length,
                itemBuilder: (context, intdex) {
                  final product = state.products[intdex];
                  final intCart = state.cartIds.contains(product.id);

                  return Card(
                    key: ValueKey(product.id),
                    child: Column(
                      children: [
                        Flexible(
                          child: Image.network(product.image),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        OutlinedButton(
                            onPressed: intCart
                                ? () => _removeFromCart(product.id)
                                : () => _addToCart(product.id),
                            style: ButtonStyle(
                              padding: MaterialStatePropertyAll(
                                EdgeInsets.all(10),
                              ),
                              backgroundColor: intCart
                                  ? MaterialStatePropertyAll<Color>(
                                      Colors.black12)
                                  : null,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: intCart
                                    ? const [
                                        Icon(
                                          Icons.remove_shopping_cart,
                                          color: Colors.black45,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Remove cart',
                                          style: TextStyle(
                                            color: Colors.black45,
                                          ),
                                        )
                                      ]
                                    : const [
                                        Icon(Icons.add_shopping_cart),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("Add to Card")
                                      ],
                              ),
                            ))
                      ],
                    ),
                  );
                });
          },
        ),
      ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingActionButton(
              onPressed: _viewCart,
              tooltip: 'View Cart',
              child: const Icon(Icons.shopping_cart),
            ),
          ),
          BlocBuilder<StoreBloc, StoreState>(
            builder: (context, state) {
              if (state.cartIds.isEmpty) {
                return Container();
              }

              return Positioned(
                right: -4,
                bottom: 40,
                child: CircleAvatar(
                  backgroundColor: Colors.tealAccent,
                  radius: 12,
                  child: Text(
                    state.cartIds.length.toString(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
