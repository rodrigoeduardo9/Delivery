class AppValidators {
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^\+?[\d\-\(\)\s]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? number(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'This field is required' : null;
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    final numberError = number(value);
    if (numberError != null) return numberError;
    if (double.parse(value!.trim()) <= 0) {
      return 'Number must be greater than zero';
    }
    return null;
  }

  static String? minLength(String? value, int minLength,
      [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? match(String? value, String otherValue,
      [String fieldName = 'Passwords']) {
    if (value != otherValue) {
      return '$fieldName do not match';
    }
    return null;
  }
}
