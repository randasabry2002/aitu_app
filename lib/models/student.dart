class Student {
  final String stage;
  final String address;
  final String birthAddress;
  final String birthDate;
  final String code;
  final String department;
  final String email;
  final String factory;
  final bool factoryType;
  final String gender;
  final String name;
  final String nationalID;
  final String phone;
  final String state;
  final String? password;
  final int grade;
  Student({
    required this.stage,
    required this.address,
    required this.birthAddress,
    required this.birthDate,
    required this.code,
    required this.department,
    required this.email,
    required this.factory,
    required this.factoryType,
    required this.gender,
    required this.name,
    required this.nationalID,
    required this.phone,
    required this.state,
    this.password,
    required this.grade,
  });

  static Student fromJson(Map<String, dynamic> json) {
    // Replace the following with actual field assignments
    return Student(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      birthAddress: json['birthAddress'] ?? '',
      birthDate: json['birthDate'] ?? '',
      stage: json['stage'] ?? '',
      department: json['department'] ?? '',
      factory: json['factory'] ?? '',
      factoryType: json['factoryType'] ?? true,
      state: json['state'] ?? '',
      gender: json['gender'] ?? '',
      nationalID: json['nationalID'] ?? '',
      grade: json['grade'] ?? 0,
    );
  }
}
