import 'package:flutter/material.dart';

class AppConstants {
  // ==================== API CONFIGURATION ====================
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8080/api'; // iOS Simulator
  // static const String baseUrl = 'https://your-api-domain.com/api'; // Production

  // ==================== STORAGE KEYS ====================
  static const String sharedPreferencesKey = 'tax_app_prefs';
  static const String jwtTokenKey = 'jwt_token';
  static const String userDataKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  static const String lastSyncKey = 'last_sync';

  // ==================== TAX CONSTANTS (TANZANIA) ====================
  static const double personalRelief = 270000.0; // TSh 270,000
  static const double pensionRelief = 300000.0; // TSh 300,000
  static const double insuranceRelief = 150000.0; // TSh 150,000
  static const double skillsDevelopmentLevy = 0.05; // 5%
  static const double railwayDevelopmentLevy = 0.05; // 5%
  static const double vatRate = 0.18; // 18%
  static const double vatExemptThreshold = 10000000.0; // TSh 10,000,000

  // ==================== FILE UPLOAD LIMITS ====================
  static const double maxFileSizeMB = 10.0;
  static const int maxFileSizeBytes = 10485760; // 10MB

  static const List<String> allowedFileExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
    'xls',
    'xlsx'
  ];

  // ==================== PAYE TAX SLABS (TANZANIA 2024) ====================
  static const List<TaxSlab> payeSlabs = [
    TaxSlab(0, 270000, 0), // 0%
    TaxSlab(270001, 520000, 0.08), // 8%
    TaxSlab(520001, 760000, 0.20), // 20%
    TaxSlab(760001, 1000000, 0.25), // 25%
    TaxSlab(1000001, 10000000, 0.30), // 30%
    TaxSlab(10000001, double.infinity, 0.35), // 35%
  ];

  // ==================== VALIDATION PATTERNS ====================
  static const String panRegex = '[A-Z]{5}[0-9]{4}[A-Z]{1}';
  static const String mobileRegex = r'^[6-9]\d{9}$';
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String aadharRegex = r'^\d{4}\s\d{4}\s\d{4}$';
  static const String ifscRegex = r'^[A-Z]{4}0[A-Z0-9]{6}$';

  // ==================== DATE FORMATS ====================
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm:ss';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // ==================== ASSESSMENT YEARS ====================
  static const List<String> assessmentYears = [
    '2025/2026',
    '2024/2025',
    '2023/2024',
    '2022/2023',
    '2021/2022',
  ];

  // ==================== FILING TYPES ====================
  static const List<String> filingTypes = [
    'ORIGINAL',
    'REVISED',
    'BELATED',
  ];

  // ==================== TAX RETURN STATUS ====================
  static const String statusDraft = 'DRAFT';
  static const String statusSubmitted = 'SUBMITTED';
  static const String statusProcessing = 'PROCESSING';
  static const String statusAssessed = 'ASSESSED';
  static const String statusCompleted = 'COMPLETED';
  static const String statusRejected = 'REJECTED';

  static const List<String> statusList = [
    statusDraft,
    statusSubmitted,
    statusProcessing,
    statusAssessed,
    statusCompleted,
    statusRejected,
  ];

  // ==================== TAXPAYER TYPES ====================
  static const List<String> taxpayerTypes = [
    'INDIVIDUAL',
    'COMPANY',
    'SOLE_PROPRIETOR',
    'NGO',
  ];

  // ==================== BUSINESS SECTORS ====================
  static const List<Map<String, String>> businessSectors = [
    {'value': 'AGRICULTURE', 'label': 'Agriculture'},
    {'value': 'MINING', 'label': 'Mining'},
    {'value': 'MANUFACTURING', 'label': 'Manufacturing'},
    {'value': 'CONSTRUCTION', 'label': 'Construction'},
    {'value': 'TRANSPORT', 'label': 'Transport & Logistics'},
    {'value': 'TOURISM', 'label': 'Tourism & Hospitality'},
    {'value': 'TRADE', 'label': 'Trade & Commerce'},
    {'value': 'FINANCE', 'label': 'Financial Services'},
    {'value': 'TECHNOLOGY', 'label': 'Technology'},
    {'value': 'EDUCATION', 'label': 'Education'},
    {'value': 'HEALTH', 'label': 'Healthcare'},
    {'value': 'REAL_ESTATE', 'label': 'Real Estate'},
    {'value': 'ENERGY', 'label': 'Energy'},
    {'value': 'TELECOMMUNICATION', 'label': 'Telecommunication'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  // ==================== TRA REGIONS ====================
  static const List<Map<String, String>> traRegions = [
    {'value': 'DAR_ES_SALAAM', 'label': 'Dar es Salaam'},
    {'value': 'ARUSHA', 'label': 'Arusha'},
    {'value': 'MWANZA', 'label': 'Mwanza'},
    {'value': 'MBEYA', 'label': 'Mbeya'},
    {'value': 'TANGA', 'label': 'Tanga'},
    {'value': 'DODOMA', 'label': 'Dodoma'},
    {'value': 'MOROGORO', 'label': 'Morogoro'},
    {'value': 'KILIMANJARO', 'label': 'Kilimanjaro'},
    {'value': 'TABORA', 'label': 'Tabora'},
    {'value': 'KIGOMA', 'label': 'Kigoma'},
    {'value': 'RUVUMA', 'label': 'Ruvuma'},
    {'value': 'LINDI', 'label': 'Lindi'},
    {'value': 'MTWARA', 'label': 'Mtwara'},
    {'value': 'IRINGA', 'label': 'Iringa'},
    {'value': 'MANYARA', 'label': 'Manyara'},
    {'value': 'GEITA', 'label': 'Geita'},
    {'value': 'KATAVI', 'label': 'Katavi'},
    {'value': 'NJOMBE', 'label': 'Njombe'},
    {'value': 'SIMIYU', 'label': 'Simiyu'},
    {'value': 'RUKWA', 'label': 'Rukwa'},
    {'value': 'SINGIDA', 'label': 'Singida'},
    {'value': 'SHINYANGA', 'label': 'Shinyanga'},
    {'value': 'MARA', 'label': 'Mara'},
    {'value': 'KAGERA', 'label': 'Kagera'},
  ];
}

// ==================== TAX SLAB CLASS ====================
class TaxSlab {
  final double min;
  final double max;
  final double rate;

  const TaxSlab(this.min, this.max, this.rate);
}

// ==================== APP COLORS ====================
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFFA000);

  // Status Colors
  static const Color success = Color(0xFF388E3C);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);
  static const Color pending = Color(0xFFFF9800);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Tanzanian Flag Colors
  static const Color flagGreen = Color(0xFF1EBE53);
  static const Color flagYellow = Color(0xFFFBD914);
  static const Color flagBlack = Color(0xFF1A1A1A);
  static const Color flagBlue = Color(0xFF00A3E0);
}

// ==================== APP STRINGS ====================
class AppStrings {
  // App
  static const String appName = 'TaxCompliance TZ';
  static const String appTagline = 'Simplify Your Tax Filing';
  static const String currency = 'TSh';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String username = 'Username';
  static const String fullName = 'Full Name';
  static const String tinNumber = 'TIN Number';
  static const String mobileNumber = 'Mobile Number';
  static const String confirmPassword = 'Confirm Password';
  static const String rememberMe = 'Remember Me';
  static const String forgotPassword = 'Forgot Password?';

  // Tax
  static const String fileReturn = 'File Tax Return';
  static const String totalIncome = 'Total Income';
  static const String deductions = 'Deductions';
  static const String taxableIncome = 'Taxable Income';
  static const String taxPayable = 'Tax Payable';
  static const String totalLiability = 'Total Liability';
  static const String assessmentYear = 'Assessment Year';
  static const String filingType = 'Filing Type';
  static const String refundAmount = 'Refund Amount';
  static const String taxPaid = 'Tax Paid';

  // Documents
  static const String uploadDocument = 'Upload Document';
  static const String documentType = 'Document Type';
  static const String description = 'Description';
  static const String selectFile = 'Select File';
  static const String allowedFileTypes =
      'Allowed: PDF, JPG, PNG, DOC, XLS (Max 10MB)';

  // Messages
  static const String loading = 'Loading...';
  static const String success = 'Success!';
  static const String error = 'Error!';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String noData = 'No data found';
  static const String dataSaved = 'Data saved successfully';
  static const String dataUpdated = 'Data updated successfully';
  static const String dataDeleted = 'Data deleted successfully';

  // Confirmation
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmSubmit =
      'Are you sure you want to submit this tax return?';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidMobile =
      'Please enter a valid 10-digit mobile number';
  static const String invalidTIN = 'Please enter a valid TIN number (9 digits)';
  static const String passwordMismatch = 'Passwords do not match';
  static const String passwordLength = 'Password must be at least 6 characters';
  static const String invalidAmount = 'Please enter a valid amount';
}
