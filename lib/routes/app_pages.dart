// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/employee_controller.dart';
import '../controllers/product_controller.dart';
import '../repositories/auth_repository.dart';
import '../repositories/employee_repository.dart';
import '../repositories/product_repository.dart';
import '../views/employee_form_page.dart';
import '../views/employee_list_page.dart';
import '../views/login_page.dart';
import '../views/product_list_page.dart';

abstract class AppRoutes {
  static const LOGIN = '/login';
  static const PRODUCTS = '/products';
  static const EMPLOYEES = '/employees';
  static const EMPLOYEE_FORM = '/employee-form';
}

class AppPages {
  static const INITIAL = AppRoutes.LOGIN;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthRepository>()) {
          Get.lazyPut<AuthRepository>(() => AuthRepository());
        }
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController(authRepository: Get.find<AuthRepository>()));
        }
      }),
    ),
    GetPage(
      name: AppRoutes.PRODUCTS,
      page: () => const ProductListPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProductRepository>()) {
          Get.lazyPut<ProductRepository>(() => ProductRepository());
        }
        if (!Get.isRegistered<ProductController>()) {
          Get.lazyPut<ProductController>(() => ProductController(productRepository: Get.find<ProductRepository>()));
        }
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.EMPLOYEES,
      page: () => const EmployeeListPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<EmployeeRepository>()) {
          Get.lazyPut<EmployeeRepository>(() => EmployeeRepository());
        }
        if (!Get.isRegistered<EmployeeController>()) {
          Get.lazyPut<EmployeeController>(() => EmployeeController(employeeRepository: Get.find<EmployeeRepository>()));
        }
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut<AuthController>(() => AuthController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.EMPLOYEE_FORM,
      page: () => const EmployeeFormPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<EmployeeRepository>()) {
          Get.lazyPut<EmployeeRepository>(() => EmployeeRepository());
        }
        if (!Get.isRegistered<EmployeeController>()) {
          Get.lazyPut<EmployeeController>(() => EmployeeController(employeeRepository: Get.find<EmployeeRepository>()));
        }
      }),
    ),
  ];
}
