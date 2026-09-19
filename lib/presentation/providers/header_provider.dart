import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mutable header title shown by the static demo shell.
final headerTitleProvider = StateProvider<String>(
      (ref) => 'Static technical publication viewer',
);

/// Mutable header subtitle shown by the static demo shell.
final headerSubtitleProvider = StateProvider<String>(
      (ref) => 'AeroSlate portfolio demo',
);
