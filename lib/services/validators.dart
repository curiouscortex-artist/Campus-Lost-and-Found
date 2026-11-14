import 'dart:convert';
import 'package:crypto/crypto.dart';

class Validators {
  // Regex Examples for Defense:
  // Email: Standard email pattern
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Phone: 10-15 digits
  static final RegExp phoneRegex = RegExp(
    r'^\+?[0-9]{10,15}$',
  );

  // Password: 8+ chars, upper, lower, number, special char
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Item Title: 5-60 characters
  static final RegExp itemTitleRegex = RegExp(
    r'^.{5,60}$',
  );

  // Date: YYYY-MM-DD
  static final RegExp dateRegex = RegExp(
    r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$',
  );

  // Price / Quantity: numeric only
  static final RegExp numericRegex = RegExp(
    r'^\d+(\.\d{1,2})?$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (!phoneRegex.hasMatch(value.trim())) return 'Enter valid phone (10-15 digits)';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (!passwordRegex.hasMatch(value)) {
      return 'Must be 8+ chars, include upper, lower, digit & special char (@\$!%*?&)';
    }
    return null;
  }

  static String? validateItemTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Item title is required';
    if (!itemTitleRegex.hasMatch(value.trim())) return 'Title must be 5 to 60 characters long';
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Date is required';
    if (!dateRegex.hasMatch(value.trim())) return 'Format must be YYYY-MM-DD';
    return null;
  }

  static String? validateNumeric(String? value) {
    if (value == null || value.trim().isEmpty) return 'Field is required';
    if (!numericRegex.hasMatch(value.trim())) return 'Enter a valid number';
    return null;
  }

  // Password Hashing Utility
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
