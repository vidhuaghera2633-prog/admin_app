import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/otp_input_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;
  String _otpValue = '';
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w > 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWide ? _wideLayout() : _narrowLayout(),
    );
  }

  Widget _wideLayout() => Row(
    children: [
      Expanded(flex: 5, child: _leftPanel()),
      Expanded(flex: 5, child: _rightPanel()),
    ],
  );

  Widget _narrowLayout() => SingleChildScrollView(
    child: Column(children: [
      SizedBox(height: 200, child: _compactHeader()),
      _rightPanel(),
    ]),
  );

  Widget _compactHeader() => Container(
    color: AppColors.slate900,
    child: Stack(
      children: [
        Positioned(top: -80, left: -80, child: _glow(220, AppColors.primary.withAlpha(38))),
        Positioned(bottom: -70, right: -40, child: _glow(180, AppColors.indigo600.withAlpha(30))),
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Center(
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.build_rounded, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'TechServe Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _leftPanel() => Container(
    color: AppColors.slate900,
    child: Stack(children: [
      Positioned(top: -80, left: -80, child: _glow(300, AppColors.primary.withAlpha(38))),
      Positioned(bottom: 100, right: -60, child: _glow(250, AppColors.indigo600.withAlpha(30))),
      Positioned(top: 200, right: 60, child: _glow(180, AppColors.secondary.withAlpha(25))),
      Positioned.fill(child: CustomPaint(painter: _GridPainter())),
      Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.build_rounded, color: Colors.white, size: 40),
            ).animate().slideX(begin: -0.5).fadeIn(),
            const SizedBox(height: 24),
            const Text('TechServe Admin',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800))
                .animate().slideX(begin: -0.3).fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            Text('Complete field service management platform for home appliance repair companies.',
              style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 15, height: 1.6))
                .animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 40),
            ...[
              'Manage complaints end-to-end',
              'Track technicians in real-time',
              'Generate detailed reports',
              'Smart scheduling & dispatch',
            ].asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: AppColors.primary.withAlpha(50), shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: AppColors.primary, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Text(e.value, style: TextStyle(color: Colors.white.withAlpha(217), fontSize: 14)),
                ],
              ),
            ).animate().slideX(begin: -0.2).fadeIn(delay: Duration(milliseconds: 300 + e.key * 80))),
          ],
        ),
      ),
    ]),
  );

  Widget _glow(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)]),
  );

  Widget _rightPanel() {
    final auth = context.watch<AuthProvider>();
    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: auth.step == AuthStep.credentials ? _credentialsForm(auth) : _otpForm(auth),
          ),
        ),
      ),
    );
  }

  Widget _credentialsForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.gray900))
          .animate().slideY(begin: 0.3).fadeIn(),
        const SizedBox(height: 8),
        const Text('Sign in to your admin account', style: TextStyle(color: AppColors.gray500, fontSize: 15))
          .animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _methodTab('Email', LoginMethod.email, auth),
              _methodTab('Mobile', LoginMethod.mobile, auth),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 24),
        if (auth.method == LoginMethod.email) ...[
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline), labelText: 'Email Address'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ] else
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.smartphone_outlined), labelText: 'Phone Number'),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v!), activeColor: AppColors.primary),
              const Text('Remember me', style: TextStyle(fontSize: 14, color: AppColors.gray600)),
            ]),
            TextButton(onPressed: () {}, child: const Text('Forgot password?', style: TextStyle(color: AppColors.primary))),
          ],
        ),
        const SizedBox(height: 24),
        AppLoadingButton(
          label: auth.method == LoginMethod.email ? 'Sign In' : 'Continue',
          isLoading: auth.isLoading,
          onPressed: () async {
            try {
              if (auth.method == LoginMethod.email) {
                await auth.signInWithEmail(_emailCtrl.text, _passCtrl.text);
              } else {
                await auth.sendOtp(_phoneCtrl.text);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            }
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            TextButton(onPressed: () => context.go('/register'), child: const Text('Register')),
          ],
        ),
      ].animate(interval: 50.ms).slideY(begin: 0.2).fadeIn(),
    );
  }

  Widget _methodTab(String label, LoginMethod method, AuthProvider auth) {
    final selected = auth.method == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => auth.setMethod(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected ? [const BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))] : [],
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: selected ? AppColors.gray900 : AppColors.gray500)),
        ),
      ),
    );
  }

  Widget _otpForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: AppColors.indigo50, shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 36),
          ),
        ).animate().scale().fadeIn(),
        const SizedBox(height: 24),
        const Center(child: Text('Two-Factor Auth', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
        const SizedBox(height: 8),
        Center(child: Text('Enter the 6-digit code sent to your ${auth.method == LoginMethod.email ? "email" : "mobile"}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.gray500, fontSize: 14))),
        const SizedBox(height: 32),
        OTPInputRow(onCompleted: (val) => setState(() => _otpValue = val)),
        const SizedBox(height: 32),
        AppLoadingButton(
          label: 'Verify & Sign In',
          isLoading: auth.isLoading,
          onPressed: _otpValue.length == 6 ? () async {
            await auth.verifyOtp(_otpValue);
          } : null,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              onPressed: auth.goBack,
            ),
            TextButton(onPressed: () => auth.sendOtp(_phoneCtrl.text), child: const Text('Resend code')),
          ],
        ),
      ],
    ).animate().scale(begin: const Offset(0.95, 0.95)).fadeIn();
  }
}

class AppLoadingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  const AppLoadingButton({super.key, required this.label, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(8)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
