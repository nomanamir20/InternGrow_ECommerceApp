import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Streams the current Firebase auth state — screens can watch this to
/// reactively rebuild when the user logs in/out, instead of manually
/// checking currentUser in initState.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});