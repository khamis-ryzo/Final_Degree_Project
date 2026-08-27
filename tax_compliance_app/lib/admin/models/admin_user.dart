import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminUser {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String tinNumber;
  final String? mobileNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? occupation;
  final String? businessName;
  final String? businessSector;
  final bool isVatRegistered;
  final String? vatRegistrationNumber;
  final bool hasPaye;
  final String? traRegion;
  final String? traBranch;
  final bool emailVerified;
  final bool phoneVerified;
  final bool isActive;
  final bool isLocked;
  final String? lockReason;
  final int failedLoginAttempts;
  final DateTime? lastLogin;
  final DateTime? lastPasswordChange;
  final DateTime? passwordExpiryDate;
  final String role;
  final String taxpayerType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String? notes;

  // Permission flags
  final bool canManageUsers;
  final bool canManageTaxReturns;
  final bool canManageTaxRules;
  final bool canViewReports;
  final bool canManageSystem;
  final bool canManageDocuments;

  AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.tinNumber,
    this.mobileNumber,
    this.dateOfBirth,
    this.address,
    this.occupation,
    this.businessName,
    this.businessSector,
    this.isVatRegistered = false,
    this.vatRegistrationNumber,
    this.hasPaye = false,
    this.traRegion,
    this.traBranch,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.isActive = true,
    this.isLocked = false,
    this.lockReason,
    this.failedLoginAttempts = 0,
    this.lastLogin,
    this.lastPasswordChange,
    this.passwordExpiryDate,
    required this.role,
    this.taxpayerType = 'INDIVIDUAL',
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.notes,
    this.canManageUsers = false,
    this.canManageTaxReturns = false,
    this.canManageTaxRules = false,
    this.canViewReports = false,
    this.canManageSystem = false,
    this.canManageDocuments = false,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      tinNumber: json['tinNumber'] ?? '',
      mobileNumber: json['mobileNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      address: json['address'],
      occupation: json['occupation'],
      businessName: json['businessName'],
      businessSector: json['businessSector'],
      isVatRegistered: json['isVatRegistered'] ?? false,
      vatRegistrationNumber: json['vatRegistrationNumber'],
      hasPaye: json['hasPaye'] ?? false,
      traRegion: json['traRegion'],
      traBranch: json['traBranch'],
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      isLocked: json['isLocked'] ?? false,
      lockReason: json['lockReason'],
      failedLoginAttempts: json['failedLoginAttempts'] ?? 0,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      lastPasswordChange: json['lastPasswordChange'] != null
          ? DateTime.parse(json['lastPasswordChange'])
          : null,
      passwordExpiryDate: json['passwordExpiryDate'] != null
          ? DateTime.parse(json['passwordExpiryDate'])
          : null,
      role: json['role'] ?? 'ROLE_USER',
      taxpayerType: json['taxpayerType'] ?? 'INDIVIDUAL',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isDeleted: json['isDeleted'] ?? false,
      notes: json['notes'],
      canManageUsers: json['canManageUsers'] ?? false,
      canManageTaxReturns: json['canManageTaxReturns'] ?? false,
      canManageTaxRules: json['canManageTaxRules'] ?? false,
      canViewReports: json['canViewReports'] ?? false,
      canManageSystem: json['canManageSystem'] ?? false,
      canManageDocuments: json['canManageDocuments'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'tinNumber': tinNumber,
      'mobileNumber': mobileNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'occupation': occupation,
      'businessName': businessName,
      'businessSector': businessSector,
      'isVatRegistered': isVatRegistered,
      'vatRegistrationNumber': vatRegistrationNumber,
      'hasPaye': hasPaye,
      'traRegion': traRegion,
      'traBranch': traBranch,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'isActive': isActive,
      'isLocked': isLocked,
      'lockReason': lockReason,
      'failedLoginAttempts': failedLoginAttempts,
      'lastLogin': lastLogin?.toIso8601String(),
      'lastPasswordChange': lastPasswordChange?.toIso8601String(),
      'passwordExpiryDate': passwordExpiryDate?.toIso8601String(),
      'role': role,
      'taxpayerType': taxpayerType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'notes': notes,
      'canManageUsers': canManageUsers,
      'canManageTaxReturns': canManageTaxReturns,
      'canManageTaxRules': canManageTaxRules,
      'canViewReports': canViewReports,
      'canManageSystem': canManageSystem,
      'canManageDocuments': canManageDocuments,
    };
  }

  // ==================== HELPER GETTERS ====================

  String get displayName => fullName;

  String get shortName {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1][0]}.';
    }
    return fullName;
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  String get roleDisplay {
    switch (role) {
      case 'ROLE_ADMIN':
        return 'Administrator';
      case 'ROLE_SUPER_ADMIN':
        return 'Super Administrator';
      case 'ROLE_TRA_OFFICER':
        return 'TRA Officer';
      case 'ROLE_ACCOUNTANT':
        return 'Accountant';
      case 'ROLE_AUDITOR':
        return 'Auditor';
      default:
        return 'User';
    }
  }

  String get roleIcon {
    switch (role) {
      case 'ROLE_ADMIN':
        return '👨‍💼';
      case 'ROLE_SUPER_ADMIN':
        return '👑';
      case 'ROLE_TRA_OFFICER':
        return '🏛️';
      case 'ROLE_ACCOUNTANT':
        return '💰';
      case 'ROLE_AUDITOR':
        return '📊';
      default:
        return '👤';
    }
  }

  Color get roleColor {
    switch (role) {
      case 'ROLE_ADMIN':
        return const Color(0xFF1976D2);
      case 'ROLE_SUPER_ADMIN':
        return const Color(0xFF6A1B9A);
      case 'ROLE_TRA_OFFICER':
        return const Color(0xFF2E7D32);
      case 'ROLE_ACCOUNTANT':
        return const Color(0xFFF57F17);
      case 'ROLE_AUDITOR':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF757575);
    }
  }

  String get statusDisplay {
    if (!isActive) return 'Inactive';
    if (isLocked) return 'Locked';
    if (isPasswordExpired()) return 'Password Expired';
    return 'Active';
  }

  Color get statusColor {
    if (!isActive) return Colors.red;
    if (isLocked) return Colors.orange;
    if (isPasswordExpired()) return Colors.orange;
    return Colors.green;
  }

  IconData get statusIcon {
    if (!isActive) return Icons.block;
    if (isLocked) return Icons.lock;
    if (isPasswordExpired()) return Icons.warning;
    return Icons.check_circle;
  }

  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  String get formattedUpdatedAt {
    return DateFormat('dd MMM yyyy, hh:mm a').format(updatedAt);
  }

  String get formattedLastLogin {
    if (lastLogin == null) return 'Never';
    return DateFormat('dd MMM yyyy, hh:mm a').format(lastLogin!);
  }

  String get formattedDateOfBirth {
    if (dateOfBirth == null) return 'Not set';
    return DateFormat('dd MMM yyyy').format(dateOfBirth!);
  }

  String get formattedPasswordExpiry {
    if (passwordExpiryDate == null) return 'Never';
    return DateFormat('dd MMM yyyy').format(passwordExpiryDate!);
  }

  String get taxpayerTypeDisplay {
    switch (taxpayerType) {
      case 'INDIVIDUAL':
        return 'Individual';
      case 'COMPANY':
        return 'Company';
      case 'SOLE_PROPRIETOR':
        return 'Sole Proprietor';
      case 'NGO':
        return 'NGO';
      default:
        return taxpayerType;
    }
  }

  // ==================== VALIDATION METHODS ====================

  bool isPasswordExpired() {
    if (passwordExpiryDate == null) return false;
    return DateTime.now().isAfter(passwordExpiryDate!);
  }

  bool isAccountLocked() {
    return isLocked || failedLoginAttempts >= 5;
  }

  bool isActiveAccount() {
    return isActive && !isLocked && !isPasswordExpired();
  }

  bool hasPermission(String permission) {
    switch (permission) {
      case 'manage_users':
        return canManageUsers || isAdmin() || isSuperAdmin();
      case 'manage_tax_returns':
        return canManageTaxReturns || isAdmin() || isSuperAdmin();
      case 'manage_tax_rules':
        return canManageTaxRules || isAdmin() || isSuperAdmin();
      case 'view_reports':
        return canViewReports || isAdmin() || isSuperAdmin();
      case 'manage_system':
        return canManageSystem || isSuperAdmin();
      case 'manage_documents':
        return canManageDocuments || isAdmin() || isSuperAdmin();
      default:
        return false;
    }
  }

  bool isAdmin() {
    return role == 'ROLE_ADMIN' || role == 'ROLE_SUPER_ADMIN';
  }

  bool isSuperAdmin() {
    return role == 'ROLE_SUPER_ADMIN';
  }

  bool isTRAOfficer() {
    return role == 'ROLE_TRA_OFFICER';
  }

  bool hasFullAccess() {
    return isAdmin() || isSuperAdmin();
  }

  // ==================== COPY WITH ====================

  AdminUser copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? tinNumber,
    String? mobileNumber,
    DateTime? dateOfBirth,
    String? address,
    String? occupation,
    String? businessName,
    String? businessSector,
    bool? isVatRegistered,
    String? vatRegistrationNumber,
    bool? hasPaye,
    String? traRegion,
    String? traBranch,
    bool? emailVerified,
    bool? phoneVerified,
    bool? isActive,
    bool? isLocked,
    String? lockReason,
    int? failedLoginAttempts,
    DateTime? lastLogin,
    DateTime? lastPasswordChange,
    DateTime? passwordExpiryDate,
    String? role,
    String? taxpayerType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    String? notes,
    bool? canManageUsers,
    bool? canManageTaxReturns,
    bool? canManageTaxRules,
    bool? canViewReports,
    bool? canManageSystem,
    bool? canManageDocuments,
  }) {
    return AdminUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      tinNumber: tinNumber ?? this.tinNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      businessName: businessName ?? this.businessName,
      businessSector: businessSector ?? this.businessSector,
      isVatRegistered: isVatRegistered ?? this.isVatRegistered,
      vatRegistrationNumber:
          vatRegistrationNumber ?? this.vatRegistrationNumber,
      hasPaye: hasPaye ?? this.hasPaye,
      traRegion: traRegion ?? this.traRegion,
      traBranch: traBranch ?? this.traBranch,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      isActive: isActive ?? this.isActive,
      isLocked: isLocked ?? this.isLocked,
      lockReason: lockReason ?? this.lockReason,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lastLogin: lastLogin ?? this.lastLogin,
      lastPasswordChange: lastPasswordChange ?? this.lastPasswordChange,
      passwordExpiryDate: passwordExpiryDate ?? this.passwordExpiryDate,
      role: role ?? this.role,
      taxpayerType: taxpayerType ?? this.taxpayerType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      notes: notes ?? this.notes,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canManageTaxReturns: canManageTaxReturns ?? this.canManageTaxReturns,
      canManageTaxRules: canManageTaxRules ?? this.canManageTaxRules,
      canViewReports: canViewReports ?? this.canViewReports,
      canManageSystem: canManageSystem ?? this.canManageSystem,
      canManageDocuments: canManageDocuments ?? this.canManageDocuments,
    );
  }
}

// ==================== ADMIN USER FILTERS ====================

class AdminUserFilter {
  final String? search;
  final String? role;
  final bool? isActive;
  final bool? isLocked;
  final String? traRegion;
  final String? taxpayerType;
  final DateTime? fromDate;
  final DateTime? toDate;

  AdminUserFilter({
    this.search,
    this.role,
    this.isActive,
    this.isLocked,
    this.traRegion,
    this.taxpayerType,
    this.fromDate,
    this.toDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'role': role,
      'isActive': isActive,
      'isLocked': isLocked,
      'traRegion': traRegion,
      'taxpayerType': taxpayerType,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
    };
  }
}

// ==================== ADMIN USER STATISTICS ====================

class AdminUserStats {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int lockedUsers;
  final int admins;
  final int traOfficers;
  final int accountants;
  final int auditors;
  final int regularUsers;
  final int newUsersLast7Days;
  final int newUsersLast30Days;
  final int usersByRegion;
  final int usersByTaxpayerType;

  AdminUserStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.lockedUsers,
    required this.admins,
    required this.traOfficers,
    required this.accountants,
    required this.auditors,
    required this.regularUsers,
    required this.newUsersLast7Days,
    required this.newUsersLast30Days,
    required this.usersByRegion,
    required this.usersByTaxpayerType,
  });

  factory AdminUserStats.fromJson(Map<String, dynamic> json) {
    return AdminUserStats(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      inactiveUsers: json['inactiveUsers'] ?? 0,
      lockedUsers: json['lockedUsers'] ?? 0,
      admins: json['admins'] ?? 0,
      traOfficers: json['traOfficers'] ?? 0,
      accountants: json['accountants'] ?? 0,
      auditors: json['auditors'] ?? 0,
      regularUsers: json['regularUsers'] ?? 0,
      newUsersLast7Days: json['newUsersLast7Days'] ?? 0,
      newUsersLast30Days: json['newUsersLast30Days'] ?? 0,
      usersByRegion: json['usersByRegion'] ?? 0,
      usersByTaxpayerType: json['usersByTaxpayerType'] ?? 0,
    );
  }
}
