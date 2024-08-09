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

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    required this.product,
    super.key,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ImageCache imageCache = PaintingBinding.instance.imageCache;

  @override
  void initState() {
    super.initState();

    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB
  }

  Future<void> addImageToCache() async {
    final ImageProvider provider = NetworkImage(widget.product.imageUrl);
    await precacheImage(provider, context);
    print('Image added to cache');
  }

  void removeImageFromCache() {
    final ImageProvider provider = NetworkImage(widget.product.imageUrl);
    imageCache.evict(provider);
    print('Image removed from cache');
  }

  void clearCache() {
    imageCache.clear();
    print('Cache cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: addImageToCache,
              child: const Text('Add Image to Cache'),
            ),
            ElevatedButton(
              onPressed: removeImageFromCache,
              child: const Text('Remove Image from Cache'),
            ),
            ElevatedButton(
              onPressed: clearCache,
              child: const Text('Clear Cache'),
            ),
            Image.network(
              widget.product.imageUrl,
              // cacheWidth: 100,
              // cacheHeight: 100,
              loadingBuilder: (context, child, loadingProgress) {
                print('loadingProgress: ${loadingProgress != null ? loadingProgress.cumulativeBytesLoaded : 0}');

                return loadingProgress == null ? child : const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.product.description),
            ),
          ],
        ),
      ),
    );
  }
}
