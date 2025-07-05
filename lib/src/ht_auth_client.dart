//
// ignore_for_file: comment_references

import 'dart:async';

import 'package:ht_shared/ht_shared.dart';

/// {@template ht_auth_client}
/// Abstract interface for authentication operations.
///
/// Implementations of this class provide concrete mechanisms for
/// user authentication (e.g., via API, Firebase, etc.), supporting
/// email+code and anonymous flows.
///
/// All methods must adhere to the standardized exception handling
/// defined in `package:ht_shared/exceptions.dart`. Implementations are
/// responsible for catching specific underlying errors (e.g., network,
/// server errors) and mapping them to the appropriate [HtHttpException]
/// subtypes.
/// {@endtemplate}
abstract class HtAuthClient {
  /// {@macro ht_auth_client}
  const HtAuthClient();

  /// Stream emitting the current authenticated [User] or `null`.
  ///
  /// Emits a new value whenever the authentication state changes
  /// (e.g., after successful sign-in/verification, sign-out, or token refresh).
  /// This is the primary way for UI layers to reactively update based on
  /// the user's authentication status.
  Stream<User?> get authStateChanges;

  /// Retrieves the currently authenticated [User], if any.
  ///
  /// Returns the [User] object if a user is currently signed in and their
  /// session/token is valid. Returns `null` otherwise.
  /// This can be useful for initial checks but `authStateChanges` should be
  /// preferred for reactive updates.
  ///
  /// Throws exceptions like [NetworkException] or [ServerException] if
  /// checking the current user status requires a network call that fails.
  Future<User?> getCurrentUser();

  /// Initiates the sign-in/sign-up process using the email+code flow.
  ///
  /// This method is context-aware.
  /// - For standard flows, it triggers the backend to send a verification code
  ///   to the user's [email].
  /// - For privileged flows (e.g., dashboard login), setting
  ///   [isDashboardLogin] to `true` signals the backend to perform stricter
  ///   validation (e.g., checking if the user exists and has required roles)
  ///   before sending a code.
  ///
  /// Throws:
  /// - [InvalidInputException] if the email format is invalid.
  /// - [UnauthorizedException] if [isDashboardLogin] is true and the user
  ///   does not exist.
  /// - [ForbiddenException] if [isDashboardLogin] is true and the user lacks
  ///   the required permissions.
  /// - [NetworkException] for network issues.
  /// - [ServerException] for backend errors.
  Future<void> requestSignInCode(
    String email, {
    bool isDashboardLogin = false,
  });

  /// Verifies the email code provided by the user and completes sign-in/sign-up.
  ///
  /// This method is context-aware.
  /// - For standard flows, it verifies the [code] for the given [email] and
  ///   either signs in an existing user or creates a new one.
  /// - For privileged flows (e.g., dashboard login), setting
  ///   [isDashboardLogin] to `true` ensures that the verification process
  ///   is strictly for login and will not create a new account.
  ///
  /// On success, returns an [AuthSuccessResponse] containing the authenticated
  /// [User] and a new token.
  ///
  /// Throws:
  /// - [InvalidInputException] if the email or code format is invalid.
  /// - [AuthenticationException] if the code is incorrect or expired.
  /// - [NotFoundException] if [isDashboardLogin] is true and the user account
  ///   does not exist (as a safeguard).
  /// - [NetworkException] for network issues.
  /// - [ServerException] for backend errors.
  Future<AuthSuccessResponse> verifySignInCode(
    String email,
    String code, {
    bool isDashboardLogin = false,
  });

  /// Signs in the user anonymously.
  ///
  /// The implementation should request the backend to:
  /// 1. Create a new anonymous user record (e.g., with `isAnonymous: true`).
  /// 2. Generate a unique user ID for this anonymous user.
  /// 3. Issue an authentication token associated with this anonymous ID.
  /// 4. Return the newly created anonymous [User] object and token in an
  ///    [AuthSuccessResponse].
  ///
  /// This allows users to use the application and potentially save data
  /// before creating a permanent account.
  ///
  /// Returns an [AuthSuccessResponse] containing the anonymous [User] and
  /// token upon successful anonymous sign-in.
  ///
  /// Throws:
  /// - [NetworkException] for network issues during the request.
  /// - [ServerException] for backend errors during anonymous user creation.
  /// - [OperationFailedException] for other failures.
  Future<AuthSuccessResponse> signInAnonymously();

  /// Signs out the current user (whether authenticated normally or anonymously).
  ///
  /// The implementation should:
  /// 1. Clear any locally stored authentication tokens or session data.
  /// 2. Optionally, notify the backend to invalidate the session/token,
  ///    especially if using opaque tokens or if immediate server-side
  ///    revocation is desired.
  ///
  /// After successful sign-out, the [authStateChanges] stream should emit `null`.
  ///
  /// Throws:
  /// - [NetworkException] if notifying the backend fails due to network issues.
  /// - [ServerException] if the backend encounters an error during token
  ///   invalidation.
  /// - [OperationFailedException] for other failures during the sign-out
  ///   process.
  Future<void> signOut();
}
