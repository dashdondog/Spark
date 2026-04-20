import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  final String role; // 'customer' or 'clinic'
  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  bool get _isCustomer => widget.role == 'customer';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final auth = context.read<AuthProvider>();
    String? error;

    if (_isLogin) {
      error = await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    } else {
      error = await auth.signUp(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _nameCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() { _loading = false; _error = error; });

    if (error == null) {
      context.go(_isCustomer ? '/customer' : '/company');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _isCustomer ? AppTheme.primary : const Color(0xFF00BFA5);
    final title = _isCustomer ? 'Үйлчлүүлэгч' : 'Эмнэлэг / Эмч';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _isCustomer
                        ? Icons.favorite_rounded
                        : Icons.medical_services_rounded,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? 'Нэвтрэх' : 'Бүртгүүлэх',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),

                if (!_isLogin) ...[
                  _field(
                    controller: _nameCtrl,
                    label: 'Нэр',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Нэр оруулна уу' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                _field(
                  controller: _emailCtrl,
                  label: 'И-мэйл',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? 'И-мэйл оруулна уу' : null,
                ),
                const SizedBox(height: 16),
                _field(
                  controller: _passwordCtrl,
                  label: 'Нууц үг',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textLight,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                      (v?.length ?? 0) < 6 ? 'Нууц үг хамгийн багадаа 6 тэмдэгт' : null,
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppTheme.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Нэвтрэх' : 'Бүртгүүлэх',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isLogin = !_isLogin;
                      _error = null;
                    }),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
                        children: [
                          TextSpan(
                            text: _isLogin
                                ? 'Бүртгэлгүй юу? '
                                : 'Бүртгэлтэй юу? ',
                          ),
                          TextSpan(
                            text: _isLogin ? 'Бүртгүүлэх' : 'Нэвтрэх',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
