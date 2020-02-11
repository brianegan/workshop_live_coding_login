import 'package:login_demo_live_code/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository implements IAuthRepository {
  final ILocalStorageDataSource storage;
  final IWebClient webClient;

  AuthRepository(this.storage, this.webClient);

  @override
  Future<User> login(String email, String password) async {
    final user = await webClient.login(email, password);
    storage.saveUserId(user.id);
    return user;
  }

  @override
  Future<void> logout() async {
    await storage.clear();
    await webClient.logout();
  }

  @override
  Future<User> currentUser() async {
    final userId = await storage.loadUserId();
    if (userId != null) {
      return User(userId);
    } else {
      return User.loggedOutUser;
    }
  }
}

abstract class ILocalStorageDataSource {
  Future<void> saveUserId(int id);

  Future<int> loadUserId();

  Future<void> clear();
}

class LocalStorage implements ILocalStorageDataSource {
  final String key;
  final SharedPreferences preferences;

  LocalStorage(this.preferences, {this.key = 'userId'});

  @override
  Future<void> clear() {
    return preferences.remove(key);
  }

  @override
  Future<int> loadUserId() async {
    return preferences.getInt(key);
  }

  @override
  Future<void> saveUserId(int id) {
    return preferences.setInt(key, id);
  }
}

abstract class IWebClient {
  Future<User> login(String email, String password);

  Future<void> logout();
}

class WebClient implements IWebClient {
  @override
  Future<User> login(String email, String password) async {
    return User(1);
  }

  @override
  Future<void> logout() async {}
}
