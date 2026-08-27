
class Validators {
  // Required field validator
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Email validator
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  // Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  // Confirm password validator
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // PAN Number validator
  static String? panNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN Number is required';
    }
    
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid PAN number (e.g., ABCDE1234F)';
    }
    
    return null;
  }
  
  // Mobile number validator
  static String? mobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    
    final mobileRegex = RegExp(r'^0\d{9}$');
    if (!mobileRegex.hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit mobile number starting with 0';
    }
    
    return null;
  }
  
  // Aadhar number validator
  static String? aadharNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhar number is required';
    }
    
    final aadharRegex = RegExp(r'^\d{4}\s\d{4}\s\d{4}$');
    if (!aadharRegex.hasMatch(value.trim())) {
      return 'Please enter a valid Aadhar number (e.g., 1234 5678 9012)';
    }
    
    return null;
  }
  
  // IFSC code validator
  static String? ifscCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!ifscRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid IFSC code';
    }
    
    return null;
  }
  
  // Amount validator
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    
    final amountValue = double.tryParse(value);
    if (amountValue == null || amountValue <= 0) {
      return 'Please enter a valid positive amount';
    }
    
    return null;
  }
  
  // Year validator
  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    
    final yearValue = int.tryParse(value);
    if (yearValue == null || yearValue < 1900 || yearValue > DateTime.now().year) {
      return 'Please enter a valid year';
    }
    
    return null;
  }
  
  // URL validator
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // PIN code validator
  static String? pinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN code is required';
    }
    
    final pinRegex = RegExp(r'^[1-9][0-9]{5}$');
    if (!pinRegex.hasMatch(value.trim())) {
      return 'Please enter a valid 6-digit PIN code';
    }
    
    return null;
  }
  
  // Name validator (only letters and spaces)
  static String? name(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Please enter a valid $fieldName (only letters and spaces)';
    }
    
    return null;
  }
  
  // Age validator (must be >= 18)
  static String? age(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Date of birth is required';
    }
    
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    
    return null;
  }
  
  // Form field validator (combines multiple validators)
  static String? validateFormField({
    required String? value,
    required String fieldName,
    bool isRequired = true,
    bool isEmail = false,
    bool isMobile = false,
    bool isPAN = false,
    int? minLength,
    int? maxLength,
    RegExp? pattern,
  }) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return '$fieldName is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      if (isEmail && email(value) != null) {
        return email(value);
      }
      
      if (isMobile && mobileNumber(value) != null) {
        return mobileNumber(value);
      }
      
      if (isPAN && panNumber(value) != null) {
        return panNumber(value);
      }
      
      if (minLength != null && value.length < minLength) {
        return '$fieldName must be at least $minLength characters';
      }
      
      if (maxLength != null && value.length > maxLength) {
        return '$fieldName must not exceed $maxLength characters';
      }
      
      if (pattern != null && !pattern.hasMatch(value)) {
        return 'Please enter a valid $fieldName';
      }
    }
    
    return null;
  }
}