import 'package:ht_auth_client/src/models/user.dart';
import 'package:test/test.dart';

void main() {
  group('User Model', () {
    const id = 'test-id';
    const email = 'test@example.com';

    test('supports value equality', () {
      expect(
        const User(id: id, email: email, isAnonymous: false),
        equals(const User(id: id, email: email, isAnonymous: false)),
      );
      expect(
        const User(id: id, email: email, isAnonymous: false),
        isNot(
          equals(
            const User(id: 'other-id', email: email, isAnonymous: false),
          ),
        ),
      );
      expect(
        const User(id: id, email: email, isAnonymous: false),
        isNot(
          equals(
            const User(
              id: id,
              email: 'other@example.com',
              isAnonymous: false,
            ),
          ),
        ),
      );
      expect(
        const User(id: id, email: email, isAnonymous: false),
        isNot(equals(const User(id: id, email: email, isAnonymous: true))),
      );
    });

    test('has correct toString', () {
      expect(
        const User(id: id, email: email, isAnonymous: false).toString(),
        equals('User(id: $id, email: $email, isAnonymous: false)'),
      );
      expect(
        const User(id: id, isAnonymous: true).toString(),
        equals('User(id: $id, email: null, isAnonymous: true)'),
      );
    });

    // Basic test for JSON serialization - assumes build_runner generated correctly
    test('can be serialized and deserialized', () {
      const user = User(id: id, email: email, isAnonymous: false);
      final json = user.toJson();
      final deserializedUser = User.fromJson(json);
      expect(deserializedUser, equals(user));

      const anonUser = User(id: id, isAnonymous: true);
      final anonJson = anonUser.toJson();
      final deserializedAnonUser = User.fromJson(anonJson);
      expect(deserializedAnonUser, equals(anonUser));
    });
  });
}
