import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_network_example/bloc/products/products_bloc.dart';
import 'package:image_network_example/model/product.dart';
import 'package:image_network_example/repository/product_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ProductRepository(),
      child: BlocProvider(
        create: (context) => ProductsBloc(
          repository: RepositoryProvider.of<ProductRepository>(context),
        )..add(LoadProducts()),
        child: const MaterialApp(
          title: 'Приложение для продуктов',
          home: ProductListPage(),
        ),
      ),
    );
  }
}

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список продуктов'),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoaded) {
            final products = state.products;

            return ListView.separated(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.title),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            );
          } else if (state is ProductsError) {
            return const Center(child: Text('Ошибка загрузки продуктов'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({
    required this.product,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl,
              loadingBuilder: (context, child, loadingProgress) {
                print('loadingProgress: ${loadingProgress != null ? loadingProgress.cumulativeBytesLoaded : 0}');

                return loadingProgress == null ? child : const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(product.description),
            ),
          ],
        ),
      ),
    );
  }
}
