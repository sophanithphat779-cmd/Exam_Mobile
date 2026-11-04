import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/auth_repository.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({AuthRepository? authRepository})
      : authRepository = authRepository ?? AuthRepository();

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);
  final RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Checks if the user already has a saved JWT token
  Future<void> checkAuthStatus() async {
    try {
      final hasToken = await authRepository.isLoggedIn();
      if (hasToken) {
        isLoggedIn.value = true;
        currentUser.value = await authRepository.getCurrentUser();
      } else {
        isLoggedIn.value = false;
        currentUser.value = null;
      }
    } catch (_) {
      isLoggedIn.value = false;
    }
  }

  /// Performs user login with JWT authentication
  Future<void> login(String username, String password) async {
    final u = username.trim();
    final p = password.trim();

    if (u.isEmpty || p.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter both username and password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await authRepository.login(u, p);
      currentUser.value = user;
      isLoggedIn.value = true;

      Get.snackbar(
        'Success',
        'Welcome back, ${user['firstName'] ?? u}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );

      // Navigate to products/home screen
      Get.offAllNamed(AppRoutes.PRODUCTS);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs out user and clears stored JWT credentials
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await authRepository.logout();
      isLoggedIn.value = false;
      currentUser.value = null;

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );

      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

