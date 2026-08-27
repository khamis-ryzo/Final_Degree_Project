class Formatters {
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _monthShortNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _pad(int value, int width) => value.toString().padLeft(width, '0');

  static String _formatNumberWithCommas(num number, {int decimalPlaces = 0}) {
    final sign = number < 0 ? '-' : '';
    final absValue = number.abs();
    final fixed = absValue.toStringAsFixed(decimalPlaces);
    final parts = fixed.split('.');
    final integerStr = parts[0];
    final fraction = decimalPlaces > 0 ? '.${parts[1]}' : '';

    final buffer = StringBuffer();
    var count = 0;
    for (var i = integerStr.length - 1; i >= 0; i--) {
      buffer.write(integerStr[i]);
      count++;
      if (i > 0 && (count == 3 || (count > 3 && (count - 3) % 2 == 0))) {
        buffer.write(',');
      }
    }

    final groupedInteger = buffer.toString().split('').reversed.join();
    return '$sign$groupedInteger$fraction';
  }

  static String _formatDateTime(DateTime dateTime, String pattern) {
    final hour24 = dateTime.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final replacements = <String, String>{
      'yyyy': dateTime.year.toString(),
      'yy': dateTime.year.toString().substring(2),
      'MMMM': _monthNames[dateTime.month - 1],
      'MMM': _monthShortNames[dateTime.month - 1],
      'MM': _pad(dateTime.month, 2),
      'M': dateTime.month.toString(),
      'dd': _pad(dateTime.day, 2),
      'd': dateTime.day.toString(),
      'hh': _pad(hour12, 2),
      'h': hour12.toString(),
      'HH': _pad(hour24, 2),
      'H': hour24.toString(),
      'mm': _pad(dateTime.minute, 2),
      'm': dateTime.minute.toString(),
      'ss': _pad(dateTime.second, 2),
      'a': hour24 >= 12 ? 'PM' : 'AM',
    };

    var result = pattern;
    for (final token in replacements.keys) {
      result = result.replaceAll(token, replacements[token]!);
    }

    return result;
  }

  // Format currency (INR)
  static String formatCurrency(double amount) {
    return '₹${_formatNumberWithCommas(amount, decimalPlaces: 2)}';
  }

  // Format currency without symbol
  static String formatCurrencyWithoutSymbol(double amount) {
    return _formatNumberWithCommas(amount, decimalPlaces: 2);
  }

  // Format date
  static String formatDate(DateTime? date, {String pattern = 'dd MMM yyyy'}) {
    if (date == null) return 'N/A';
    return _formatDateTime(date, pattern);
  }

  // Format time
  static String formatTime(DateTime? time, {String pattern = 'hh:mm a'}) {
    if (time == null) return 'N/A';
    return _formatDateTime(time, pattern);
  }

  // Format datetime
  static String formatDateTime(
    DateTime? dateTime, {
    String pattern = 'dd MMM yyyy, hh:mm a',
  }) {
    if (dateTime == null) return 'N/A';
    return _formatDateTime(dateTime, pattern);
  }

  // Format number with commas
  static String formatNumber(dynamic number, {int decimalPlaces = 0}) {
    if (number == null) return '0';

    final numValue = number is String ? double.tryParse(number) : number;
    if (numValue == null) return '0';

    return _formatNumberWithCommas(numValue, decimalPlaces: decimalPlaces);
  }

  // Format percentage
  static String formatPercentage(double value, {int decimalPlaces = 2}) {
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  // Format PAN number (XXXXX1234X)
  static String formatPAN(String pan) {
    if (pan.length != 10) return pan;
    return pan.substring(0, 5) + pan.substring(5, 9) + pan.substring(9);
  }

  // Format mobile number (XXXXX XXXXX)
  static String formatMobile(String mobile) {
    if (mobile.length != 10) return mobile;
    return '${mobile.substring(0, 5)} ${mobile.substring(5)}';
  }

  // Format Aadhar number (XXXX XXXX XXXX)
  static String formatAadhar(String aadhar) {
    if (aadhar.length != 12) return aadhar;
    return '${aadhar.substring(0, 4)} ${aadhar.substring(4, 8)} ${aadhar.substring(8)}';
  }

  // Format IFSC code (XXXX0XXXXXX)
  static String formatIFSC(String ifsc) {
    return ifsc.toUpperCase();
  }

  // Format assessment year (YYYY-YY)
  static String formatAssessmentYear(int year) {
    return '$year-${(year + 1).toString().substring(2)}';
  }

  // Parse assessment year
  static int parseAssessmentYear(String assessmentYear) {
    return int.parse(assessmentYear.split('-')[0]);
  }

  // Get financial year from date
  static String getFinancialYear(DateTime date) {
    final year = date.year;
    final month = date.month;

    if (month >= 4) {
      return '$year-${(year + 1).toString().substring(2)}';
    } else {
      return '${year - 1}-${year.toString().substring(2)}';
    }
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    var size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Truncate text
  static String truncateText(
    String text,
    int maxLength, {
    String suffix = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // Convert to title case
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // Mask sensitive data (e.g., PAN, mobile)
  static String maskSensitiveData(
    String data, {
    int unmaskedStart = 2,
    int unmaskedEnd = 2,
  }) {
    if (data.length <= unmaskedStart + unmaskedEnd) {
      return '*' * data.length;
    }

    final start = data.substring(0, unmaskedStart);
    final end = data.substring(data.length - unmaskedEnd);
    final maskedLength = data.length - unmaskedStart - unmaskedEnd;
    final masked = '*' * maskedLength;

    return '$start$masked$end';
  }
}
