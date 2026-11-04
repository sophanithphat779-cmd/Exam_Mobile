import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';

class EmployeeController extends GetxController {
  final EmployeeRepository employeeRepository;

  EmployeeController({EmployeeRepository? employeeRepository})
      : employeeRepository = employeeRepository ?? EmployeeRepository();

  final RxList<Employee> employees = <Employee>[].obs;
  final RxList<Employee> filteredEmployees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  /// Fetches employees from repository
  Future<void> fetchEmployees() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final list = await employeeRepository.getEmployees();
      employees.assignAll(list);
      _applySearch();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh
  Future<void> refreshEmployees() async {
    await fetchEmployees();
  }

  /// Search and filter employees
  void search(String query) {
    searchQuery.value = query;
    _applySearch();
  }

  void _applySearch() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredEmployees.assignAll(employees);
    } else {
      filteredEmployees.assignAll(
        employees.where((e) {
          return e.fullName.toLowerCase().contains(query) ||
              e.email.toLowerCase().contains(query) ||
              e.position.toLowerCase().contains(query) ||
              e.department.toLowerCase().contains(query);
        }).toList(),
      );
    }
  }

  /// Add new employee
  Future<bool> addEmployee(Employee employee) async {
    try {
      isSaving.value = true;
      final created = await employeeRepository.addEmployee(employee);
      employees.insert(0, created);
      _applySearch();

      Get.back(); // Return to employee list
      Get.snackbar(
        'Success',
        'Employee "${created.fullName}" was added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add employee: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update existing employee
  Future<bool> updateEmployee(Employee employee) async {
    try {
      isSaving.value = true;
      final updated = await employeeRepository.updateEmployee(employee);

      final index = employees.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        employees[index] = updated;
      }
      _applySearch();

      Get.back(); // Return to employee list
      Get.snackbar(
        'Success',
        'Employee "${updated.fullName}" was updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update employee: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Show confirmation dialog and delete employee
  void confirmAndDelete(Employee employee) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Delete Employee', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${employee.fullName}"?\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back(); // Close dialog first
              if (employee.id != null) {
                await _delete(employee.id!, employee.fullName);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(int id, String name) async {
    try {
      await employeeRepository.deleteEmployee(id);
      employees.removeWhere((e) => e.id == id);
      _applySearch();

      Get.snackbar(
        'Deleted',
        'Employee "$name" was removed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete employee: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }
}

