import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';

class BookingPage extends StatefulWidget {
  final String clinicId;
  final String serviceId;

  const BookingPage({
    super.key,
    required this.clinicId,
    required this.serviceId,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late DateTime _selectedDate;
  String? _selectedTime;
  bool _isLoading = false;

  static const List<String> _timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30',
  ];

  static const List<String> _dayNames = [
    'Дав', 'Мяг', 'Лха', 'Пүр', 'Баа', 'Бям', 'Ням'
  ];
  static const List<String> _monthNames = [
    '1-р', '2-р', '3-р', '4-р', '5-р', '6-р',
    '7-р', '8-р', '9-р', '10-р', '11-р', '12-р',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  List<DateTime> get _nextSevenDays {
    final now = DateTime.now();
    return List.generate(7, (i) => now.add(Duration(days: i + 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final clinic = provider.getClinicById(widget.clinicId);
        final service = provider.getServiceById(widget.serviceId);

        if (clinic == null || service == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Захиалгын алдаа')),
            body: const Center(child: Text('Клиник эсвэл үйлчилгээ олдсонгүй')),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Цаг захиалах'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.canPop() ? context.pop() : context.go('/customer'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClinicSummary(clinic, service),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                  const SizedBox(height: 24),
                  _buildTimeSection(),
                  const SizedBox(height: 24),
                  _buildPatientInfo(),
                  const SizedBox(height: 32),
                  _buildConfirmButton(service),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Clinic Summary ────────────────────────────────────────────────────────
  Widget _buildClinicSummary(Clinic clinic, Service service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                clinic.name[0],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic.name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  service.name,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 13, color: AppTheme.textLight),
                    const SizedBox(width: 3),
                    Text('${service.duration} min',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight)),
                    const SizedBox(width: 14),
                    const Icon(Icons.attach_money_rounded,
                        size: 14, color: AppTheme.primary),
                    Text(
                      service.price.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Picker Strip ────────────────────────────────────────────────────
  Widget _buildDateSection() {
    final days = _nextSevenDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Огноо сонгох',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;
              final dayName = _dayNames[date.weekday - 1];
              final monthName = _monthNames[date.month - 1];

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDate = date;
                  _selectedTime = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 62,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha:0.35)
                            : const Color(0x0A000000),
                        blurRadius: isSelected ? 10 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isSelected ? Colors.white70 : AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color:
                              isSelected ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        monthName,
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isSelected ? Colors.white60 : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Time Slot Grid ───────────────────────────────────────────────────────
  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Цаг сонгох',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((time) {
            final isSelected = _selectedTime == time;
            return GestureDetector(
              onTap: () => setState(() => _selectedTime = time),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.divider,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textMedium,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Patient Info Form ────────────────────────────────────────────────────
  Widget _buildPatientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Өвчтөний мэдээлэл',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Бүтэн нэр',
            hintText: 'Бүтэн нэрээ оруулна уу',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Нэрээ оруулна уу' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Утасны дугаар',
            hintText: 'Утасны дугаараа оруулна уу',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Утасны дугаараа оруулна уу' : null,
        ),
      ],
    );
  }

  // ── Confirm Button ───────────────────────────────────────────────────────
  Widget _buildConfirmButton(Service service) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitBooking,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                'Захиалга баталгаажуулах  ·  \$${service.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Цаг сонгоно уу')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final parts = _selectedTime!.split(':');
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final provider = context.read<BookingProvider>();

      await Future.delayed(const Duration(seconds: 1));

      if (!context.mounted) return;

      provider.createBooking(
            clinicId: widget.clinicId,
            serviceId: widget.serviceId,
            dateTime: dateTime,
            customerName: _nameController.text.trim(),
            customerEmail: '',
            customerPhone: _phoneController.text.trim(),
          );

      if (context.mounted) _showSuccessDialog();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha:0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Захиалга баталгаажлаа!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark),
              ),
              const SizedBox(height: 10),
              const Text(
                'Таны цаг амжилттай\nзахиалагдлаа.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 14,
                    height: 1.5),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.day} ${['1-р сар','2-р сар','3-р сар','4-р сар','5-р сар','6-р сар','7-р сар','8-р сар','9-р сар','10-р сар','11-р сар','12-р сар'][_selectedDate.month - 1]}  ·  $_selectedTime',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/customer');
                  },
                  child: const Text('Нүүр хуудас руу буцах'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
