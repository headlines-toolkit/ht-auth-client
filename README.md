# ht_auth_client

![coverage: xx](https://img.shields.io/badge/coverage-xx-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

This package defines the abstract interface (`HtAuthClient`) for authentication operations within the Headlines Toolkit ecosystem. It provides a contract that concrete implementations (e.g., API clients, Firebase clients, in-memory mocks) must adhere to.

The interface supports both an email+code password-less authentication and an anonymous authentication flow.

## Getting Started

This package is intended to be used as an interface dependency. Add it to your `pubspec.yaml`:

```yaml
dependencies:
  ht_auth_client:
    git:
      url: https://github.com/headlines-toolkit/ht-auth-client.git
      # Consider adding a ref: tag for version pinning
```

Then import the library:

```dart
import 'package:ht_auth_client/ht_auth_client.dart';
```

You will typically interact with a concrete implementation of `HtAuthClient` provided via dependency injection.

## Features

The `HtAuthClient` interface defines the following core authentication capabilities:

*   **`authStateChanges`**: A `Stream<User?>` that emits the current authenticated `User` or `null` whenever the authentication state changes (sign-in, sign-out). Ideal for reactive UI updates.
*   **`getCurrentUser()`**: An asynchronous method `Future<User?>` to retrieve the currently signed-in `User`, if any.
*   **`requestSignInCode(String email, {bool isDashboardLogin = false})`**: Initiates the passwordless sign-in flow. It's context-aware: for standard sign-in, it sends a code; for dashboard login (`isDashboardLogin: true`), it first validates the user's existence and permissions.
*   **`verifySignInCode(String email, String code, {bool isDashboardLogin = false})`**: Verifies the email code. For standard flows, it signs in or creates a user. For dashboard login (`isDashboardLogin: true`), it strictly performs a login and does not create new accounts. Returns a `Future<AuthSuccessResponse>`.
*   **`signInAnonymously()`**: Signs the user in anonymously, creating a temporary user identity on the backend and returning a `Future<AuthSuccessResponse>` containing the anonymous `User` and token.
*   **`signOut()`**: Signs out the current user (normal or anonymous).
*   **`linkEmail(String email)`**: Initiates the process of linking an email to an existing anonymous account.
*   **`verifyLinkEmail(String code)`**: Completes the email linking process by verifying the code. On success, it returns a `Future<AuthSuccessResponse>` with the now-permanent user and a new token.
*   **`deleteAccount()`**: Allows an authenticated user to delete their own account.

Error handling is standardized using exceptions defined in the `ht_shared` package. Implementations must map underlying errors to appropriate `HtHttpException` subtypes.

## Usage

Here's a conceptual example of how a consuming application (like a Flutter app using BLoC) might interact with an injected `HtAuthClient` instance:

```dart
// Assuming 'authClient' is an instance of a concrete HtAuthClient implementation

// Listen to authentication state changes
final authSubscription = authClient.authStateChanges.listen((user) {
  if (user != null) {
    print('User signed in: ${user.id}, Roles: ${user.roles}');
    // Navigate to home screen, update UI
  } else {
    print('User signed out');
    // Navigate to login screen
  }
});

// --- Email+Code Flow (Dashboard Example) ---

Future<void> startDashboardSignIn(String email) async {
  try {
    // For a privileged dashboard login, set the flag to true
    await authClient.requestSignInCode(email, isDashboardLogin: true);
    // Navigate to code entry screen
  } on UnauthorizedException {
    print('This email is not registered for dashboard access.');
  } on ForbiddenException {
    print('You do not have permission to access the dashboard.');
  } catch (e) {
    print('Failed to request code: $e');
  }
}

// --- Email+Code Flow ---

Future<void> startEmailSignIn(String email) async {
  try {
    await authClient.requestSignInCode(email);
    // Navigate to code entry screen
  } on InvalidInputException catch (e) {
    print('Invalid email format: ${e.message}');
  } on NetworkException {
    print('Network error requesting code.');
  } catch (e) {
    print('Failed to request code: $e');
  }
}

Future<void> verifyCode(String email, String code) async {
  try {
    final authResponse = await authClient.verifySignInCode(email, code);
    final user = authResponse.user;
    final token = authResponse.token;
    print('Successfully signed in/up user: ${user.id}, token: $token');
    // authStateChanges will emit the new user
  } on AuthenticationException catch (e) {
    print('Invalid code: ${e.message}');
  } on InvalidInputException catch (e) {
    print('Invalid input: ${e.message}');
  } on NetworkException {
    print('Network error verifying code.');
  } catch (e) {
    print('Failed to verify code: $e');
  }
}

// --- Anonymous Flow ---

Future<void> signInAnon() async {
  try {
    final authResponse = await authClient.signInAnonymously();
    final user = authResponse.user;
    final token = authResponse.token;
    print('Signed in anonymously: ${user.id}, token: $token');
    // authStateChanges will emit the new anonymous user
  } on NetworkException {
    print('Network error signing in anonymously.');
  } catch (e) {
    print('Failed to sign in anonymously: $e');
  }
}

// --- Sign Out ---

Future<void> logOut() async {
  try {
    await authClient.signOut();
    print('Signed out successfully.');
    // authStateChanges will emit null
  } catch (e) {
    print('Failed to sign out: $e');
  }
}

// Remember to cancel streams
// authSubscription.cancel();
```

## License

This package is licensed under the [PolyForm Free Trial](LICENSE). Please review the terms before use.
