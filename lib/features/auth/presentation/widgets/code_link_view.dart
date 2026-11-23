import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../domain/desktop_server_source.dart';
import '../auth_controller.dart';

/// The 6-digit-code half of the link screen (the YouTube-style
/// alternative to scanning the QR code).
///
/// The user picks a desktop server (last-used one is offered first,
/// otherwise they type the address) and enters the 6-digit code shown
/// on the desktop's link screen. All pairing logic lives in
/// [AuthController]; this widget only collects the input.
class CodeLinkView extends ConsumerStatefulWidget {
  const CodeLinkView({super.key});

  @override
  ConsumerState<CodeLinkView> createState() => _CodeLinkViewState();
}

class _CodeLinkViewState extends ConsumerState<CodeLinkView> {
  final _serverController = TextEditingController();
  final _codeController = TextEditingController();
  final _labelController = TextEditingController(text: 'هاتف الصيدلية');

  List<DesktopServer> _servers = const [];
  bool _loadingServers = true;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _serverController.addListener(_onFieldChanged);
    _codeController.addListener(_onFieldChanged);
    _loadServers();
  }

  @override
  void dispose() {
    _serverController.dispose();
    _codeController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final canSubmit =
        _serverController.text.trim().isNotEmpty &&
        _codeController.text.trim().length == 6;
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  Future<void> _loadServers() async {
    final servers = await ref
        .read(authControllerProvider.notifier)
        .loadServers();
    if (!mounted) return;
    DesktopServer? lastUsed;
    for (final server in servers) {
      if (server.isLastUsed) {
        lastUsed = server;
        break;
      }
    }
    setState(() {
      _servers = servers;
      _loadingServers = false;
      if (lastUsed != null && _serverController.text.isEmpty) {
        _serverController.text = lastUsed.url;
      }
    });
  }

  void _submit() {
    final server = _serverController.text.trim();
    final code = _codeController.text.trim();
    if (server.isEmpty || code.length != 6) return;
    FocusScope.of(context).unfocus();
    ref
        .read(authControllerProvider.notifier)
        .pairWithCode(
          serverUrl: server,
          code: code,
          deviceLabel: _labelController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: BaloraColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.dialpad_rounded,
                  color: BaloraColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'أدخل كود الربط من الكمبيوتر',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: BaloraColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'من نظام Balora للكمبيوتر افتح شاشة الربط وانسخ الكود المكوّن من 6 أرقام، ثم أدخله هنا.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: BaloraColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // --- Server address ---
              const Text(
                'عنوان الكمبيوتر',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: BaloraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _serverController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: '192.168.1.15:4784',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dns_outlined),
                ),
              ),
              if (_loadingServers)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                )
              else if (_servers.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _servers
                      .map(
                        (server) => ActionChip(
                          avatar: const Icon(
                            Icons.history_rounded,
                            size: 16,
                          ),
                          label: Text(
                            server.isLastUsed
                                ? 'آخر خادم: ${server.url}'
                                : server.url,
                            textDirection: TextDirection.ltr,
                          ),
                          onPressed: () {
                            _serverController.text = server.url;
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),

              // --- 6-digit code ---
              const Text(
                'كود الربط (6 أرقام)',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: BaloraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _codeController,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 10,
                  color: BaloraColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(letterSpacing: 10),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // --- Device label ---
              const Text(
                'اسم الهاتف على الكمبيوتر',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: BaloraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _labelController,
                maxLength: 60,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _canSubmit && !isLoading ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaloraColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'ربط',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
