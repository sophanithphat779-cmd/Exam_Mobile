class Employee {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String position;
  final String department;
  final double salary;
  final String avatar;

  Employee({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    this.salary = 0.0,
    this.avatar = '',
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Employee';
  }

  String get initials {
    final f = firstName.trim().isNotEmpty ? firstName.trim()[0].toUpperCase() : '';
    final l = lastName.trim().isNotEmpty ? lastName.trim()[0].toUpperCase() : '';
    final init = '$f$l';
    return init.isNotEmpty ? init : 'E';
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Extract first and last name, or split from full name
    String fName = json['firstName']?.toString() ?? '';
    String lName = json['lastName']?.toString() ?? '';
    if (fName.isEmpty && lName.isEmpty && json['name'] != null) {
      final parts = json['name'].toString().split(' ');
      fName = parts.isNotEmpty ? parts.first : '';
      lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    // Extract position / title (either direct or under company.title)
    String pos = json['position']?.toString() ??
        json['role']?.toString() ??
        (json['company'] is Map ? json['company']['title']?.toString() ?? '' : '');
    if (pos.isEmpty) pos = 'Team Member';

    // Extract department (either direct or under company.department)
    String dept = json['department']?.toString() ??
        (json['company'] is Map ? json['company']['department']?.toString() ?? '' : '');
    if (dept.isEmpty) dept = 'General';

    // Extract salary
    double sal = 0.0;
    if (json['salary'] is num) {
      sal = (json['salary'] as num).toDouble();
    } else if (json['salary'] != null) {
      sal = double.tryParse(json['salary'].toString()) ?? 0.0;
    }

    return Employee(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      firstName: fName,
      lastName: lName,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      position: pos,
      department: dept,
      salary: sal,
      avatar: json['avatar']?.toString() ?? json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'name': fullName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'salary': salary,
      'avatar': avatar,
    };
  }

  Employee copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? position,
    String? department,
    double? salary,
    String? avatar,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      department: department ?? this.department,
      salary: salary ?? this.salary,
      avatar: avatar ?? this.avatar,
    );
  }
}

