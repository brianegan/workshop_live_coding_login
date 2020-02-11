import 'package:flutter/cupertino.dart';

class AuthModel extends ChangeNotifier {
  final IAuthRepository repository;
  User _user;

  AuthModel(this.repository, {User user = User.loggedOutUser})
      : this._user = user;

  User get user => _user;

  bool get loggedIn => _user != User.loggedOutUser;

  bool validateEmail(String email) => email.contains('@');

  bool validatePassword(String password) => password.length >= 5;

  Future<User> init() async {
    _user = await repository.currentUser();
    notifyListeners();
    return _user;
  }

  Future<User> login(String email, String password) async {
    if (!validateEmail(email)) throw ArgumentError('Email is invalid');
    if (!validatePassword(password)) throw ArgumentError('Password is invalid');

    _user = await repository.login(email, password);
    notifyListeners();

    return _user;
  }

  Future<void> logout() async {
    _user = User.loggedOutUser;
    notifyListeners();
    repository.logout();
  }
}

abstract class IAuthRepository {
  Future<User> currentUser();

  Future<User> login(String email, String password);

  Future<void> logout();
}

class User {
  static const loggedOutUser = User(-1);

  final int id;

  const User(this.id);
}
