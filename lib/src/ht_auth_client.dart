//
// ignore_for_file: comment_references

import 'dart:async';

import 'package:ht_auth_client/src/models/user.dart';
// ignore: unused_import, allows documenting exceptions without causing warnings
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
  /// Takes the user's [email] address. The implementation should trigger the
  /// backend to generate a time-limited verification code and send it to the
  /// provided email address.
  ///
  /// The backend determines if this is a sign-in or sign-up based on whether
  /// the email already exists.
  ///
  /// Throws:
  /// - [InvalidInputException] if the email format is invalid.
  /// - [NetworkException] if the request to the backend fails due to network
  ///   issues.
  /// - [ServerException] if the backend encounters an unexpected error while
  ///   processing the request or sending the email.
  /// - [OperationFailedException] for other non-network/server related
  ///   failures during the process.
  Future<void> requestSignInCode(String email);

  /// Verifies the email code provided by the user and completes sign-in/sign-up.
  ///
  /// Takes the user's [email] and the 6-digit [code] they received.
  /// The implementation should send these to the backend for verification.
  ///
  /// If verification is successful, the backend should:
  /// 1. Log the user in (if email existed) or create the account and log in
  ///    (if email was new).
  /// 2. Issue an authentication token (e.g., JWT).
  /// 3. Return the authenticated [User] object.
  ///
  /// If the user was previously authenticated anonymously, the implementation
  /// (likely the backend) should handle linking the anonymous data to the
  /// newly verified permanent account.
  ///
  /// Returns the authenticated [User] upon successful verification.
  ///
  /// Throws:
  /// - [InvalidInputException] if the email format is invalid, the code format
  ///   is invalid, or the code is incorrect/expired.
  /// - [AuthenticationException] if the code verification fails specifically
  ///   due to invalid credentials (wrong code).
  /// - [NotFoundException] if the backend logic requires the email to exist
  ///   from a previous `requestSignInCode` call and it doesn't (edge case).
  /// - [NetworkException] for network issues during verification.
  /// - [ServerException] for backend errors during verification or account
  ///   creation/linking.
  /// - [OperationFailedException] for other failures.
  Future<User> verifySignInCode(String email, String code);

  /// Signs in the user anonymously.
  ///
  /// The implementation should request the backend to:
  /// 1. Create a new anonymous user record (e.g., with `isAnonymous: true`).
  /// 2. Generate a unique user ID for this anonymous user.
  /// 3. Issue an authentication token associated with this anonymous ID.
  /// 4. Return the newly created anonymous [User] object.
  ///
  /// This allows users to use the application and potentially save data
  /// before creating a permanent account.
  ///
  /// Returns the anonymous [User] upon successful anonymous sign-in.
  ///
  /// Throws:
  /// - [NetworkException] for network issues during the request.
  /// - [ServerException] for backend errors during anonymous user creation.
  /// - [OperationFailedException] for other failures.
  Future<User> signInAnonymously();

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
