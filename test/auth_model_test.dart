import 'package:flutter_test/flutter_test.dart';
import 'package:login_demo_live_code/auth_model.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('AuthModel', () {
    test('validates an email', () {
      final model = AuthModel(MockAuthRepository());

      expect(model.validateEmail('a@b.com'), isTrue);
      expect(model.validateEmail('aasdsd'), isFalse);
    });

    test('validates a password', () {
      final model = AuthModel(MockAuthRepository());

      expect(model.validatePassword('12345'), isTrue);
      expect(model.validatePassword('1'), isFalse);
    });

    test('allows a user to log in', () async {
      final repo = MockAuthRepository();
      final model = AuthModel(repo);
      final user = User(1);

      when(repo.login('a@b.com', '12345')).thenAnswer((_) async => user);

      expect(await model.login('a@b.com', '12345'), user);
      expect(model.user, user);
    });

    test('does not allow a user to log in with a bad email', () async {
      final repo = MockAuthRepository();
      final model = AuthModel(repo);

      expect(() async => await model.login('a', '12345'), throwsArgumentError);
    });

    test('does not allow a user to log in with a bad password', () async {
      final repo = MockAuthRepository();
      final model = AuthModel(repo);

      expect(
        () async => await model.login('a@b.com', '1'),
        throwsArgumentError,
      );
    });

    test('logged out by default', () {
      final repo = MockAuthRepository();
      final model = AuthModel(repo);

      expect(model.loggedIn, isFalse);
      expect(AuthModel(repo, user: User(1)).loggedIn, isTrue);
    });
  });
}
