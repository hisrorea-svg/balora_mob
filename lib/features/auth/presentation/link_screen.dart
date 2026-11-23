import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../core/result/result.dart';
import 'auth_controller.dart';
import 'widgets/code_link_view.dart';
import 'widgets/qr_link_view.dart';

enum _LinkMethod { qr, code }

/// Link this device to a Balora Desktop — YouTube style: the user
/// chooses either scanning the QR code or typing the 6-digit code
/// shown on the desktop's link screen.
///
/// Reachable from Settings and from the Home "not linked" banner; the
/// `/pairing` route is kept as a deep link. This screen is never an
/// entry gate any more: in guest mode the app opens on Home and the
/// user comes here explicitly.
class LinkScreen extends ConsumerStatefulWidget {
  const LinkScreen({super.key});

  @override
  ConsumerState<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends ConsumerState<LinkScreen> {
  final _qrViewKey = GlobalKey<QrLinkViewState>();
  var _method = _LinkMethod.qr;

  @override
  Widget build(BuildContext context) {
    // Listen for pairing results from either tab (Success / Error).
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        // Clear previous messages so errors never pile up.
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getErrorMessage(next.error),
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: BaloraColors.error,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (!next.isLoading && !next.hasError && next.hasValue) {
        _onPaired();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Scan QR Code to Sign In'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: BaloraColors.borderSubtle),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _MethodToggle(
              method: _method,
              onChanged: (method) {
                if (method != _method) {
                  setState(() => _method = method);
                }
              },
            ),
          ),
          Expanded(
            child: _method == _LinkMethod.qr
                ? QrLinkView(key: _qrViewKey)
                : const CodeLinkView(),
          ),
        ],
      ),
    );
  }

  Future<void> _onPaired() async {
    // Flip the link flag so the Home banner and the server-gated
    // screens update immediately.
    ref.read(authStateProvider.notifier).set(true);
    if (_method == _LinkMethod.qr) {
      // Stop the camera first and give the phone a moment to release
      // it, so the next screen does not fight over camera resources.
      await _qrViewKey.currentState?.stopCamera();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;
    // Came from Settings/Home: go back there. Otherwise (deep link)
    // go home.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }
}

/// Two-option switch between the QR scanner and the 6-digit-code form.
class _MethodToggle extends StatelessWidget {
  const _MethodToggle({required this.method, required this.onChanged});

  final _LinkMethod method;
  final ValueChanged<_LinkMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaloraColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BaloraColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleButton(
            method: _LinkMethod.qr,
            icon: Icons.qr_code_scanner_rounded,
            label: 'مسح QR',
          ),
          const SizedBox(width: 4),
          _toggleButton(
            method: _LinkMethod.code,
            icon: Icons.dialpad_rounded,
            label: 'كود 6 أرقام',
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required _LinkMethod method,
    required IconData icon,
    required String label,
  }) {
    final selected = this.method == method;
    return Expanded(
      child: Material(
        color: selected ? BaloraColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: () => onChanged(method),
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? Colors.white
                      : BaloraColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : BaloraColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
