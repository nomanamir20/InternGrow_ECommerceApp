import 'package:flutter/material.dart';

/// A single global ScaffoldMessengerKey used app-wide, instead of calling
/// ScaffoldMessenger.of(context) from individual screens. This avoids
/// SnackBars becoming orphaned/stuck when their originating screen is
/// popped or replaced (a known issue with go_router's shell routes).
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Shows a SnackBar reliably from anywhere in the app, clearing any
/// currently-visible one first so they don't stack or hang.
void showAppSnackBar(SnackBar snackBar) {
  final messenger = appMessengerKey.currentState;
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(snackBar);
}