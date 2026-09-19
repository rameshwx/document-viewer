import 'package:share_plus/share_plus.dart';

/// Shares a bundled document using the browser-visible asset URL.
Future<void> shareBundledDocument({
  required String assetPath,
  required String title,
}) async {
  // Flutter serves declared assets below the web asset bundle prefix.
  final url = Uri.base.resolve('assets/$assetPath').toString();
  await Share.share(url, subject: title);
}
