import 'constants.dart';

class AppValidators {
  AppValidators._();

  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (value.length > AppConstants.maxEmailLength) {
      return 'Email is too long';
    }

    final emailRegExp = RegExp(AppConstants.emailRegex);
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }

    return null;
  }

  // Confirm Password Validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name Validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Name is too long';
    }

    final nameRegExp = RegExp(AppConstants.nameRegex);
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  // Phone Number Validation (Optional)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegExp = RegExp(AppConstants.phoneRegex);
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Required Field Validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Number Validation
  static String? validateNumber(String? value, {bool isRequired = false}) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return null;
    }

    if (isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }

    final number = double.tryParse(value!);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return 'Number cannot be negative';
    }

    return null;
  }

  // Budget Validation (for Real Estate)
  static String? validateBudget(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Budget is optional
    }

    final budget = double.tryParse(value);
    if (budget == null) {
      return 'Please enter a valid budget amount';
    }

    if (budget <= 0) {
      return 'Budget must be greater than 0';
    }

    if (budget > 999999999) { // 99 Crore limit
      return 'Budget seems too high';
    }

    return null;
  }

  // Date Validation
  static String? validateDate(String? value, {bool isRequired = false}) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return null;
    }

    if (isRequired && (value == null || value.isEmpty)) {
      return 'Date is required';
    }

    try {
      DateTime.parse(value!);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Future Date Validation (for follow-up dates)
  static String? validateFutureDate(String? value, {bool isRequired = false}) {
    final dateValidation = validateDate(value, isRequired: isRequired);
    if (dateValidation != null) {
      return dateValidation;
    }

    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDate = DateTime(date.year, date.month, date.day);

      if (selectedDate.isBefore(today)) {
        return 'Date cannot be in the past';
      }

      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Remark Validation
  static String? validateRemark(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Remark cannot be empty';
    }

    if (value.length > AppConstants.maxRemarkLength) {
      return 'Remark is too long (max ${AppConstants.maxRemarkLength} characters)';
    }

    return null;
  }

  // Custom Field Label Validation
  static String? validateCustomFieldLabel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field label is required';
    }

    if (value.trim().length < 2) {
      return 'Label must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Label is too long';
    }

    return null;
  }

  // Dropdown Options Validation
  static String? validateDropdownOptions(List<String>? options) {
    if (options == null || options.isEmpty) {
      return 'At least one option is required';
    }

    if (options.length > AppConstants.maxCustomFieldOptions) {
      return 'Too many options (max ${AppConstants.maxCustomFieldOptions})';
    }

    for (final option in options) {
      if (option.trim().isEmpty) {
        return 'Options cannot be empty';
      }
    }

    // Check for duplicates
    final uniqueOptions = options.map((e) => e.trim().toLowerCase()).toSet();
    if (uniqueOptions.length != options.length) {
      return 'Duplicate options are not allowed';
    }

    return null;
  }

  // Lead Status Validation
  static String? validateLeadStatus(String? value, List<String> allowedStatuses) {
    if (value == null || value.isEmpty) {
      return 'Status is required';
    }

    if (!allowedStatuses.contains(value)) {
      return 'Invalid status selected';
    }

    return null;
  }

  // File Size Validation
  static String? validateFileSize(int fileSizeBytes) {
    if (fileSizeBytes > AppConstants.maxFileSize) {
      final maxSizeMB = AppConstants.maxFileSize / (1024 * 1024);
      return 'File size cannot exceed ${maxSizeMB.toStringAsFixed(1)} MB';
    }

    return null;
  }

  // File Type Validation
  static String? validateFileType(String fileName, List<String> allowedTypes) {
    final extension = fileName.split('.').last.toLowerCase();

    if (!allowedTypes.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedTypes.join(', ')}';
    }

    return null;
  }

  // URL Validation (for future features)
  static String? validateUrl(String? value, {bool isRequired = false}) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return null;
    }

    if (isRequired && (value == null || value.isEmpty)) {
      return 'URL is required';
    }

    try {
      final uri = Uri.parse(value!);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  // Helper method to clean phone number
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  // Helper method to format name
  static String formatName(String name) {
    return name.trim().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Helper method to clean and validate multiple emails
  static List<String> validateMultipleEmails(String emailsString) {
    final emails = emailsString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final validEmails = <String>[];
    for (final email in emails) {
      if (validateEmail(email) == null) {
        validEmails.add(email);
      }
    }

    return validEmails;
  }
}