import 'package:ht_auth_client/ht_auth_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Create a mock implementation of HtAuthClient using mocktail
class MockHtAuthClient extends Mock implements HtAuthClient {}

void main() {
  group('HtAuthClient', () {
    test('mock can be instantiated', () {
      // Test that a mock instance can be created, confirming the interface setup
      expect(MockHtAuthClient(), isNotNull);
    });
  });
}
