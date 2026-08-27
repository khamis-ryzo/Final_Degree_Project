class MobileFormatter {
  static const String countryCode = '255';

  // Format mobile number to +255 XXX XXX XXX
  static String format(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.isEmpty) return '';

    // If number starts with 0, remove it and add country code
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // If number doesn't start with country code, add it
    if (!cleaned.startsWith(countryCode)) {
      cleaned = countryCode + cleaned;
    }

    // Format: +255 XXX XXX XXX
    if (cleaned.length >= 12) {
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9, 12)}';
    }

    return '+$cleaned';
  }

  // Validate Tanzanian mobile number
  static bool isValid(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Must be 9-12 digits
    if (cleaned.length < 9 || cleaned.length > 12) return false;

    // Check if it's a valid Tanzanian number
    if (cleaned.length == 9 && cleaned.startsWith('7')) return true;
    if (cleaned.length == 10 && cleaned.startsWith('0')) return true;
    if (cleaned.length == 12 && cleaned.startsWith('255')) return true;

    return false;
  }

  // Get raw digits only
  static String getRawDigits(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  // Check if number is from specific network
  static String getNetwork(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Remove leading zeros or country code
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.startsWith('255')) {
      cleaned = cleaned.substring(3);
    }

    // Check network prefixes
    if (cleaned.startsWith('71') || cleaned.startsWith('76')) {
      return 'TIGO';
    } else if (cleaned.startsWith('74') || cleaned.startsWith('75')) {
      return 'VODACOM';
    } else if (cleaned.startsWith('78') || cleaned.startsWith('79')) {
      return 'AIRTEL';
    } else if (cleaned.startsWith('77')) {
      return 'HALOTEL';
    } else if (cleaned.startsWith('73') || cleaned.startsWith('72')) {
      return 'TTCL';
    } else {
      return 'UNKNOWN';
    }
  }
}
