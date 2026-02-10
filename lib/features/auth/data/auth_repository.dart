import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/user_model.dart';

class AuthRepository {
  static const String _usersBoxName = 'users';
  static const String _sessionBoxName = 'auth_session';
  static const String _currentUserKey = 'current_user_id';

  late Box<UserModel> _usersBox;
  late Box<String> _sessionBox;

  Future<void> initialize() async {
    _usersBox = await Hive.openBox<UserModel>(_usersBoxName);
    _sessionBox = await Hive.openBox<String>(_sessionBoxName);
  }

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  Future<UserModel> register({
    required String email,
    required String displayName,
    required String password,
  }) async {
    // Check if email already exists
    final existingUser = _usersBox.values.where(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (existingUser.isNotEmpty) {
      throw AuthException('An account with this email already exists.');
    }

    final user = UserModel(
      id: const Uuid().v4(),
      email: email.toLowerCase().trim(),
      displayName: displayName.trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    await _usersBox.put(user.id, user);
    await _sessionBox.put(_currentUserKey, user.id);
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final hash = _hashPassword(password);
    final matches = _usersBox.values.where(
      (u) =>
          u.email.toLowerCase() == email.toLowerCase().trim() &&
          u.passwordHash == hash,
    );

    if (matches.isEmpty) {
      throw AuthException('Invalid email or password.');
    }

    final user = matches.first;
    await _sessionBox.put(_currentUserKey, user.id);
    return user;
  }

  Future<void> logout() async {
    await _sessionBox.delete(_currentUserKey);
  }

  UserModel? getCurrentUser() {
    final userId = _sessionBox.get(_currentUserKey);
    if (userId == null) return null;
    return _usersBox.get(userId);
  }

  bool get isLoggedIn => getCurrentUser() != null;
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
