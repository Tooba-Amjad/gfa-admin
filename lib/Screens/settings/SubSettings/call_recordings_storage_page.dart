import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Data backup: connect / switch / disconnect Google Drive.
/// Persists to [userapp/drive_config]. Cloud function backups data (chats, recordings etc.) to Drive when connected.
class CallRecordingsStoragePage extends StatefulWidget {
  final String currentuserid;

  const CallRecordingsStoragePage({Key? key, required this.currentuserid})
      : super(key: key);

  @override
  State<CallRecordingsStoragePage> createState() =>
      _CallRecordingsStoragePageState();
}

class _CallRecordingsStoragePageState extends State<CallRecordingsStoragePage> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>(debugLabel: 'drive_loader');
  final TextEditingController _folderIdController = TextEditingController();

  @override
  void dispose() {
    _folderIdController.dispose();
    super.dispose();
  }

  DocumentReference get _driveConfigRef =>
      FirebaseFirestore.instance.collection(DbPaths.userapp).doc(DbPaths.driveConfig);

  /// Redirect URI used when capturing the auth code in the in-app WebView. Must be added to the Web client's Authorized redirect URIs in Google Cloud Console.
  static String get _webViewRedirectUri {
    final base = AppConstants.googleDriveRedirectUri.trim();
    if (base.isEmpty) return 'http://localhost/drive-oauth-callback';
    return base.endsWith('/') ? '${base}drive-oauth-callback' : '$base/drive-oauth-callback';
  }

  Future<void> _connectDrive() async {
    if (AppConstants.googleDriveWebClientId.isEmpty) {
      Utils.toast('Configure Google Drive Web Client ID in app_constants.dart');
      return;
    }
    final redirectUri = _webViewRedirectUri;
    final scope = 'https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive';
    final authUrl = 'https://accounts.google.com/o/oauth2/v2/auth?'
        'client_id=${Uri.encodeComponent(AppConstants.googleDriveWebClientId)}'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&response_type=code'
        '&scope=${Uri.encodeComponent(scope)}'
        '&access_type=offline'
        '&prompt=consent';

    if (!mounted) return;
    final authCode = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => _DriveOAuthWebView(
          initialUrl: authUrl,
          redirectUri: redirectUri,
        ),
      ),
    );
    if (authCode == null || authCode.isEmpty) return;
    if (authCode.startsWith('ERROR:')) {
      Utils.toast('Connection failed: ${authCode.replaceFirst('ERROR: ', '')}');
      return;
    }

    ShowLoading().open(context: context, key: _keyLoader);
    try {
      final folderId = _folderIdController.text.trim().isEmpty
          ? null
          : _folderIdController.text.trim();
      final callable = FirebaseFunctions.instance.httpsCallable('exchangeCodeForTokens');
      await callable.call({
        'code': authCode,
        'folderId': folderId,
        'email': null,
        'redirectUri': redirectUri,
      });
      if (mounted) {
        ShowLoading().close(context: context, key: _keyLoader);
        Utils.toast('Drive connected. Your data will be backed up to Drive.');
      }
    } catch (e, st) {
      if (mounted) {
        ShowLoading().close(context: context, key: _keyLoader);
        Utils.toast(_driveErrorMessage(e));
        debugPrint('Drive connect error: $e\n$st');
      }
    }
  }

  /// Extract a user-friendly message from Cloud Functions or Google errors.
  String _driveErrorMessage(dynamic e) {
    if (e is FirebaseFunctionsException) {
      final code = e.code;
      final message = e.message?.toString().trim();
      final details = e.details?.toString().trim();

      // Show function-provided message/details first (most accurate).
      if (message != null && message.isNotEmpty) return message;
      if (details != null && details.isNotEmpty) return details;

      // Common cases.
      if (code == 'failed-precondition') {
        return 'Drive OAuth is not configured on server (missing client id/secret).';
      }
      if (code == 'invalid-argument') {
        return 'Invalid auth code or missing refresh token. Try disconnecting and reconnecting.';
      }
      return 'Failed to connect: $code';
    }

    final String s = e.toString();
    // Android error 12500 = SIGN_IN_FAILED: need Android OAuth client with SHA-1
    if (s.contains('12500') || (s.contains('sign_in_failed') && s.contains('ApiException'))) {
      return 'Android sign-in failed (12500). In Google Cloud Console add an OAuth 2.0 Android client with package name com.gfachatadmin.sanmiwago and your app SHA-1. See the blue info box for SHA-1 command.';
    }
    if (s.contains('redirect_uri') || s.contains('redirect_uri_mismatch')) {
      return 'Redirect URI mismatch. In Google Cloud Console, add the exact redirect URI your backend uses (e.g. ${AppConstants.googleDriveRedirectUri}) to this Web client\'s Authorized redirect URIs.';
    }
    if (s.contains('invalid_grant')) {
      return 'Auth code invalid/expired. Try again.';
    }
    if (s.contains('500') || s.contains('That\'s an error')) {
      return 'Google returned a server error (500). This is usually a redirect_uri mismatch or wrong client credentials.';
    }
    return 'Failed to connect: $e';
  }

  Future<void> _disconnectDrive() async {
    ShowLoading().open(context: context, key: _keyLoader);
    try {
      await _driveConfigRef.set({
        'connected': false,
        'provider': null,
        'refreshToken': null,
        'folderId': null,
        'email': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _folderIdController.clear();
      if (mounted) {
        ShowLoading().close(context: context, key: _keyLoader);
        Utils.toast('Drive disconnected. Data will use app storage.');
      }
    } catch (e) {
      if (mounted) {
        ShowLoading().close(context: context, key: _keyLoader);
        Utils.toast('Failed to disconnect: $e');
      }
    }
  }

  Future<void> _saveFolderId() async {
    final folderId = _folderIdController.text.trim();
    if (folderId.isEmpty) {
      Utils.toast('Enter a folder ID');
      return;
    }
    ShowLoading().open(context: context, key: _keyLoader);
    try {
      await _driveConfigRef.set({
        'folderId': folderId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ShowLoading().close(context: context, key: _keyLoader);
        Utils.toast('Folder ID updated.');
      }
    } catch (e) {
      if (mounted) {
        ShowLoading().close(context: context, key: _keyLoader);
        Utils.toast('Failed to update: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      titlespacing: 15,
      title: 'Data backup',
      body: StreamBuilder<DocumentSnapshot>(
        stream: _driveConfigRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final connected = data != null && data['connected'] == true;
          final email = data?['email']?.toString();
          final folderId = data?['folderId']?.toString();

          if (connected && (folderId == null || folderId.isEmpty)) {
            _folderIdController.text = '';
          } else if (connected && folderId != null) {
            if (_folderIdController.text != folderId) {
              _folderIdController.text = folderId;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              Text(
                'Store your data (chats, recordings etc.) in Google Drive instead of app storage. Connect a Google account and optionally choose a folder.',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 24),
              if (!connected) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: AppConstants.googleDriveWebClientId.isEmpty
                        ? null
                        : _connectDrive,
                    icon: const Icon(Icons.cloud_done),
                    label: const Text('Connect Google Drive'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              'Drive connected',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                          if (email != null && email.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Account: $email'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _connectDrive,
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    label: const Text('Switch Drive Account'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _disconnectDrive,
                    icon: const Icon(Icons.link_off, size: 20),
                    label: const Text('Revoke authorization & disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'After disconnecting you can connect a different Google account.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 24),
                Text(
                  'New data will be backed up to this Drive. Existing storage behavior applies until you disconnect.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Full-screen WebView that loads Google OAuth and returns the auth code when redirect is hit.
class _DriveOAuthWebView extends StatefulWidget {
  final String initialUrl;
  final String redirectUri;

  const _DriveOAuthWebView({
    required this.initialUrl,
    required this.redirectUri,
  });

  @override
  State<_DriveOAuthWebView> createState() => _DriveOAuthWebViewState();
}

class _DriveOAuthWebViewState extends State<_DriveOAuthWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (UrlChange change) {
            final url = change.url;
            if (url == null) return;
            if (!url.startsWith(widget.redirectUri)) return;
            final uri = Uri.parse(url);
            final code = uri.queryParameters['code'];
            final error = uri.queryParameters['error'];
            
            if (code != null && code.isNotEmpty) {
              Navigator.of(context).pop(code);
            } else if (error != null && error.isNotEmpty) {
              // Handle error (e.g., access_denied)
              debugPrint('OAuth Error: $error');
              Navigator.of(context).pop('ERROR: $error');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Google Drive'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
