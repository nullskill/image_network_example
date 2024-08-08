import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_network_example/model/product.dart';

class ProductRepository {
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  // Future<File> getImageFile(String imageUrl) async {
  //   final directory = await getTemporaryDirectory();
  //   final file = File('${directory.path}/${Uri.parse(imageUrl).pathSegments.last}');
  //   if (await file.exists()) {
  //     return file;
  //   } else {
  //     final response = await http.get(Uri.parse(imageUrl));
  //     await file.writeAsBytes(response.bodyBytes);
  //     return file;
  //   }
  // }
}
