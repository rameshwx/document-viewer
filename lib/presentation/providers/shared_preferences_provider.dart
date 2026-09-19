import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared browser preferences used by presentation settings and local state.
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((_) => SharedPreferences.getInstance());
