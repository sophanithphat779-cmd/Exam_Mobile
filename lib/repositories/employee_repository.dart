import '../core/api_client.dart';
import '../models/employee.dart';

class EmployeeRepository {
  final ApiClient apiClient;

  // In-memory synchronized cache for state persistence during session
  static final List<Employee> _employeeCache = [];
  static bool _hasLoaded = false;

  EmployeeRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  /// Retrieve list of employees from REST API or local synchronized cache
  Future<List<Employee>> getEmployees() async {
    if (_hasLoaded && _employeeCache.isNotEmpty) {
      return List<Employee>.from(_employeeCache);
    }

    try {
      final response = await apiClient.get('/users', queryParameters: {'limit': 20});
      final data = response.data;
      if (data is Map<String, dynamic> && data['users'] is List) {
        final List list = data['users'];
        final fetched = list.map((item) => Employee.fromJson(item as Map<String, dynamic>)).toList();
        _employeeCache.clear();
        _employeeCache.addAll(fetched);
        _hasLoaded = true;
        return List<Employee>.from(_employeeCache);
      }
    } catch (_) {
      // Fallback in case of network issue
    }

    if (_employeeCache.isEmpty) {
      _employeeCache.addAll(_getInitialEmployees());
      _hasLoaded = true;
    }
    return List<Employee>.from(_employeeCache);
  }

  /// Add new employee record via REST API
  Future<Employee> addEmployee(Employee employee) async {
    try {
      final response = await apiClient.post(
        '/users/add',
        data: {
          'firstName': employee.firstName,
          'lastName': employee.lastName,
          'email': employee.email,
          'phone': employee.phone,
          'company': {
            'department': employee.department,
            'title': employee.position,
          },
        },
      );
      final id = (response.data is Map && response.data['id'] != null)
          ? int.tryParse(response.data['id'].toString())
          : (DateTime.now().millisecondsSinceEpoch % 100000);

      final created = employee.copyWith(id: id ?? (DateTime.now().millisecondsSinceEpoch % 100000));
      _employeeCache.insert(0, created);
      return created;
    } catch (_) {
      // Offline fallback: create locally
      final created = employee.copyWith(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
      );
      _employeeCache.insert(0, created);
      return created;
    }
  }

  /// Update existing employee information via REST API
  Future<Employee> updateEmployee(Employee employee) async {
    if (employee.id == null) {
      throw ApiException(message: 'Employee ID is required for update.');
    }

    try {
      await apiClient.put(
        '/users/${employee.id}',
        data: {
          'firstName': employee.firstName,
          'lastName': employee.lastName,
          'email': employee.email,
          'phone': employee.phone,
          'company': {
            'department': employee.department,
            'title': employee.position,
          },
        },
      );
    } catch (_) {
      // Continue to update locally even if dummy API endpoint behaves unexpectedly
    }

    final index = _employeeCache.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      _employeeCache[index] = employee;
    } else {
      _employeeCache.insert(0, employee);
    }
    return employee;
  }

  /// Delete employee via REST API
  Future<bool> deleteEmployee(int id) async {
    try {
      await apiClient.delete('/users/$id');
    } catch (_) {
      // Continue to delete locally
    }

    _employeeCache.removeWhere((e) => e.id == id);
    return true;
  }

  List<Employee> _getInitialEmployees() {
    return [
      Employee(
        id: 1,
        firstName: 'Emily',
        lastName: 'Johnson',
        email: 'emily.johnson@x.dummyjson.com',
        phone: '+1 812-421-4823',
        position: 'Engineering Lead',
        department: 'Technology',
        salary: 95000.0,
        avatar: 'https://dummyjson.com/icon/emilys/128',
      ),
      Employee(
        id: 2,
        firstName: 'Michael',
        lastName: 'Williams',
        email: 'michael.williams@x.dummyjson.com',
        phone: '+1 423-532-3482',
        position: 'Senior Flutter Developer',
        department: 'Mobile Development',
        salary: 85000.0,
        avatar: 'https://dummyjson.com/icon/michaelw/128',
      ),
      Employee(
        id: 3,
        firstName: 'Sophia',
        lastName: 'Brown',
        email: 'sophia.brown@x.dummyjson.com',
        phone: '+1 234-567-8901',
        position: 'Product Designer (UI/UX)',
        department: 'Design',
        salary: 78000.0,
        avatar: 'https://dummyjson.com/icon/sophiab/128',
      ),
      Employee(
        id: 4,
        firstName: 'James',
        lastName: 'Davis',
        email: 'james.davis@x.dummyjson.com',
        phone: '+1 345-678-9012',
        position: 'QA Automation Engineer',
        department: 'Quality Assurance',
        salary: 72000.0,
        avatar: 'https://dummyjson.com/icon/jamesd/128',
      ),
      Employee(
        id: 5,
        firstName: 'Emma',
        lastName: 'Miller',
        email: 'emma.miller@x.dummyjson.com',
        phone: '+1 456-789-0123',
        position: 'DevOps & Cloud Engineer',
        department: 'Infrastructure',
        salary: 91000.0,
        avatar: 'https://dummyjson.com/icon/emmam/128',
      ),
    ];
  }
}

