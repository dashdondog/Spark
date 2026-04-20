import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ClinicRegisterPage extends StatefulWidget {
  const ClinicRegisterPage({super.key});

  @override
  State<ClinicRegisterPage> createState() => _ClinicRegisterPageState();
}

class _ClinicRegisterPageState extends State<ClinicRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _clinicNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _registerNumberCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _category = 'Ерөнхий';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _agreed = false;

  static const List<String> _categories = [
    'Ерөнхий',
    'Шүдний',
    'Зүрх судас',
    'Яс үе',
    'Хүүхдийн',
    'ХЧЧ',
    'Нүдний',
    'Бусад',
  ];

  @override
  void dispose() {
    _clinicNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _registerNumberCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Үйлчилгээний нөхцөлийг зөвшөөрнө үү'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                  'Клиник амжилттай бүртгэгдлээ. Шалгалт хийгдэж байна.'),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    context.go('/company');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/role'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.business_center_rounded,
                      color: AppTheme.primary, size: 34),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Клиник бүртгүүлэх',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Өөрийн эмнэлэг / клиникээ бүртгүүлж, үйлчлүүлэгчтэй холбогдоорой',
                  style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                ),
                const SizedBox(height: 28),
                _sectionLabel('Байгууллагын мэдээлэл'),
                const SizedBox(height: 12),
                _buildField(
                  controller: _clinicNameCtrl,
                  label: 'Клиникийн нэр',
                  icon: Icons.local_hospital_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Нэр оруулна уу'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildCategoryDropdown(),
                const SizedBox(height: 14),
                _buildField(
                  controller: _registerNumberCtrl,
                  label: 'Улсын бүртгэлийн дугаар',
                  icon: Icons.badge_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Бүртгэлийн дугаар оруулна уу'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _addressCtrl,
                  label: 'Хаяг',
                  icon: Icons.location_on_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Хаяг оруулна уу'
                      : null,
                ),
                const SizedBox(height: 24),
                _sectionLabel('Холбоо барих'),
                const SizedBox(height: 12),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Утасны дугаар',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Утас оруулна уу';
                    }
                    if (v.replaceAll(RegExp(r'\D'), '').length < 8) {
                      return 'Зөв утас оруулна уу';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _emailCtrl,
                  label: 'И-мэйл',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'И-мэйл оруулна уу';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Зөв и-мэйл оруулна уу';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _sectionLabel('Нэвтрэх мэдээлэл'),
                const SizedBox(height: 12),
                _buildField(
                  controller: _passwordCtrl,
                  label: 'Нууц үг',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textLight,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Нууц үг оруулна уу';
                    if (v.length < 6) return '6+ тэмдэгттэй байх';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _confirmCtrl,
                  label: 'Нууц үг давтах',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textLight,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Давтан оруулна уу';
                    if (v != _passwordCtrl.text) return 'Нууц үг таарахгүй';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Text(
                            'Үйлчилгээний нөхцөл болон нууцлалын бодлогыг хүлээн зөвшөөрч байна',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Бүртгүүлэх',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login/clinic'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                        children: [
                          TextSpan(text: 'Бүртгэлтэй юу? '),
                          TextSpan(
                            text: 'Нэвтрэх',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _category,
      decoration: InputDecoration(
        labelText: 'Чиглэл',
        prefixIcon: const Icon(Icons.medical_services_outlined),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _category = v);
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
