import 'package:get/get.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository productRepository;

  ProductController({ProductRepository? productRepository})
      : productRepository = productRepository ?? ProductRepository();

  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> categories = <String>['All'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  /// Fetches products from repository
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final list = await productRepository.getProducts();
      products.assignAll(list);

      // Extract unique categories
      final catSet = <String>{'All'};
      for (final p in list) {
        if (p.category.isNotEmpty) {
          catSet.add(p.category);
        }
      }
      categories.assignAll(catSet.toList());

      _applyFilters();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh action
  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  /// Filter products by search text
  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// Filter products by category
  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value;

    filteredProducts.assignAll(
      products.where((p) {
        final matchesQuery = query.isEmpty ||
            p.title.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);

        final matchesCategory = cat == 'All' || p.category.toLowerCase() == cat.toLowerCase();

        return matchesQuery && matchesCategory;
      }).toList(),
    );
  }
}

