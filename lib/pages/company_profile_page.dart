import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _orgCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>();
    _nameCtrl = TextEditingController(text: p.name);
    _orgCtrl = TextEditingController(text: p.org);
    _emailCtrl = TextEditingController(text: p.email);
    _phoneCtrl = TextEditingController(text: p.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _orgCtrl.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() => _editing = true);
  }

  void _cancelEdit() {
    FocusScope.of(context).unfocus();
    final p = context.read<ProfileProvider>();
    _nameCtrl.text = p.name;
    _orgCtrl.text = p.org;
    _emailCtrl.text = p.email;
    _phoneCtrl.text = p.phone;
    setState(() => _editing = false);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    context.read<ProfileProvider>().update(
          name: _nameCtrl.text.trim(),
          org: _orgCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Мэдээлэл амжилттай хадгалагдлаа'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Профайл'),
        leading: IconButton(
          icon: Icon(_editing
              ? Icons.close_rounded
              : Icons.arrow_back_rounded),
          onPressed: () => _editing ? _cancelEdit() : context.pop(),
        ),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              color: AppTheme.primary,
              tooltip: 'Засах',
              onPressed: _startEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildAvatar(),
            const SizedBox(height: 8),
            Text(
              _nameCtrl.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _orgCtrl.text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 28),
            _buildField(Icons.person_outline_rounded, 'Нэр', _nameCtrl),
            const SizedBox(height: 14),
            _buildField(Icons.business_outlined, 'Байгууллага', _orgCtrl),
            const SizedBox(height: 14),
            _buildField(Icons.email_outlined, 'И-мэйл', _emailCtrl,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _buildField(Icons.phone_outlined, 'Утас', _phoneCtrl,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 28),
            if (_editing) _buildEditActions() else _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _nameCtrl.text.isNotEmpty
                  ? _nameCtrl.text[0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (_editing)
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: const Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2)),
            ),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 15),
          ),
      ],
    );
  }

  Widget _buildField(
    IconData icon,
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: _editing,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: _editing ? Colors.white : AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textMedium,
              side: const BorderSide(color: AppTheme.divider),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Болих',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text(
              'Хадгалах',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
            SizedBox(width: 10),
            Text(
              'Гарах',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Гарах уу?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Та системээс гарахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Үгүй',
                style: TextStyle(color: AppTheme.textMedium)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Future.microtask(() {
                if (context.mounted) context.go('/');
              });
            },
            child: const Text('Гарах',
                style: TextStyle(
                    color: AppTheme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
