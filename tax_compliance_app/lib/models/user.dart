class User {
  final int? id;
  final String username;
  final String email;
  final String tinNumber; // Changed from panNumber
  final String fullName;
  final String? mobileNumber;
  final String? address;
  final String? role;
  final bool? isActive;
  final String? createdAt;

  // Additional profile fields used by tax reporting and TRA forms.
  final String? taxpayerType;
  final String? businessName;
  final String? businessSector;
  final String? traRegion;
  final String? traBranch;
  final bool? isVatRegistered;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.tinNumber,
    required this.fullName,
    this.mobileNumber,
    this.address,
    this.role,
    this.isActive,
    this.createdAt,
    this.taxpayerType,
    this.businessName,
    this.businessSector,
    this.traRegion,
    this.traBranch,
    this.isVatRegistered,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      tinNumber: json['tinNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'],
      address: json['address'],
      role: json['role'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      taxpayerType: json['taxpayerType'] ?? 'INDIVIDUAL',
      businessName: json['businessName'],
      businessSector: json['businessSector'],
      traRegion: json['traRegion'],
      traBranch: json['traBranch'],
      isVatRegistered: json['isVatRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'tinNumber': tinNumber,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'address': address,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'taxpayerType': taxpayerType,
      'businessName': businessName,
      'businessSector': businessSector,
      'traRegion': traRegion,
      'traBranch': traBranch,
      'isVatRegistered': isVatRegistered,
    };
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : {
            'id': json['id'],
            'username': json['username'] ?? '',
            'email': json['email'] ?? '',
            'tinNumber': json['tinNumber'] ?? json['panNumber'] ?? '',
            'fullName': json['fullName'] ?? '',
            'mobileNumber': json['mobileNumber'],
            'role': json['role'],
          };

    return LoginResponse(
      token: (json['token'] ?? '').toString(),
      user: User.fromJson(userJson),
    );
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String tinNumber;
  final String fullName;
  final String? mobileNumber;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.tinNumber,
    required this.fullName,
    this.mobileNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'tinNumber': tinNumber,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
    };
  }
}
