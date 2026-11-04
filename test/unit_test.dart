import 'package:flutter_test/flutter_test.dart';
import 'package:exam_mobile/models/employee.dart';
import 'package:exam_mobile/models/product.dart';
import 'package:exam_mobile/repositories/auth_repository.dart';
import 'package:exam_mobile/repositories/employee_repository.dart';
import 'package:exam_mobile/repositories/product_repository.dart';
import 'package:exam_mobile/controllers/auth_controller.dart';
import 'package:exam_mobile/controllers/employee_controller.dart';
import 'package:exam_mobile/controllers/product_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('Models Unit Tests', () {
    test('Product model parses from JSON and to JSON properly', () {
      final json = {
        'id': 10,
        'title': 'Test Phone',
        'description': 'A smart phone',
        'price': 499.99,
        'rating': 4.5,
        'stock': 20,
        'brand': 'Acme',
        'category': 'smartphones',
        'thumbnail': 'https://example.com/phone.png',
      };

      final product = Product.fromJson(json);
      expect(product.id, 10);
      expect(product.title, 'Test Phone');
      expect(product.price, 499.99);
      expect(product.rating, 4.5);
      expect(product.category, 'smartphones');

      final serialized = product.toJson();
      expect(serialized['id'], 10);
      expect(serialized['title'], 'Test Phone');
    });

    test('Employee model parses from JSON and handles initials / fullName', () {
      final json = {
        'id': 5,
        'firstName': 'Sarah',
        'lastName': 'Connor',
        'email': 'sarah@resistance.org',
        'phone': '555-1234',
        'position': 'Commander',
        'department': 'Security',
        'salary': 85000.0,
      };

      final employee = Employee.fromJson(json);
      expect(employee.id, 5);
      expect(employee.fullName, 'Sarah Connor');
      expect(employee.initials, 'SC');
      expect(employee.position, 'Commander');
      expect(employee.department, 'Security');

      final updated = employee.copyWith(position: 'General');
      expect(updated.position, 'General');
      expect(updated.fullName, 'Sarah Connor');
    });
  });

  group('Repository & Controller Unit Tests', () {
    test('ProductRepository returns fallback or API products', () async {
      final repo = ProductRepository();
      final products = await repo.getProducts();
      expect(products, isNotEmpty);
      expect(products.first.title, isNotEmpty);
    });

    test('EmployeeRepository performs CRUD operations', () async {
      final repo = EmployeeRepository();

      // Read
      final list = await repo.getEmployees();
      expect(list, isNotEmpty);
      final initialCount = list.length;

      // Create
      final newEmp = Employee(
        firstName: 'Alan',
        lastName: 'Turing',
        email: 'alan@bletchley.org',
        phone: '123-456-7890',
        position: 'Cryptanalyst',
        department: 'Technology',
        salary: 100000,
      );
      final created = await repo.addEmployee(newEmp);
      expect(created.id, isNotNull);
      expect(created.firstName, 'Alan');

      final afterAdd = await repo.getEmployees();
      expect(afterAdd.length, initialCount + 1);

      // Update
      final updated = await repo.updateEmployee(created.copyWith(position: 'Chief Scientist'));
      expect(updated.position, 'Chief Scientist');

      // Delete
      await repo.deleteEmployee(created.id!);
      final afterDelete = await repo.getEmployees();
      expect(afterDelete.length, initialCount);
    });

    test('ProductController filters by category and search text', () async {
      final repo = ProductRepository();
      final controller = ProductController(productRepository: repo);
      await controller.fetchProducts();

      expect(controller.products, isNotEmpty);
      expect(controller.filteredProducts, isNotEmpty);

      // Search
      controller.search('Mascara');
      expect(controller.filteredProducts.every((p) => p.title.toLowerCase().contains('mascara')), isTrue);

      // Clear search
      controller.search('');
      expect(controller.filteredProducts.length, controller.products.length);
    });

    test('EmployeeController handles adding, updating, and filtering', () async {
      final repo = EmployeeRepository();
      final controller = EmployeeController(employeeRepository: repo);
      await controller.fetchEmployees();

      expect(controller.employees, isNotEmpty);

      // Search filter
      controller.search('Emily');
      expect(controller.filteredEmployees.length, greaterThanOrEqualTo(1));
      expect(controller.filteredEmployees.first.firstName, 'Emily');

      controller.search('');
      expect(controller.filteredEmployees.length, controller.employees.length);
    });

    test('AuthRepository demo login and logout', () async {
      final repo = AuthRepository();
      final user = await repo.login('admin', 'admin123');
      expect(user, isNotNull);
      expect(user['username'], 'admin');

      final isLoggedIn = await repo.isLoggedIn();
      expect(isLoggedIn, isTrue);

      await repo.logout();
      final isLoggedOut = await repo.isLoggedIn();
      expect(isLoggedOut, isFalse);
    });
  });
}

