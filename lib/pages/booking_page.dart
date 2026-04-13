import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_provider.dart';
import '../l10n/app_localizations.dart';

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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final clinic = provider.getClinicById(widget.clinicId);
        final service = provider.getServiceById(widget.serviceId);

        if (clinic == null || service == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).bookingError),
            ),
            body: Center(
              child: Text(AppLocalizations.of(context).clinicServiceNotFound),
            ),
          );
        }

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).bookAppointment),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/clinic/${widget.clinicId}');
                  }
                },
              ),
            ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummary(context, clinic, service),
                  const SizedBox(height: 32),
                  _buildDateTimeSelection(context),
                  const SizedBox(height: 32),
                  _buildCustomerInfo(context),
                  const SizedBox(height: 32),
                  _buildBookingButton(context, clinic, service),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingSummary(
    BuildContext context,
    Clinic clinic,
    Service service,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Захиалгын дүнasd',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              title: AppLocalizations.of(context).clinic,
              value: clinic.name,
              icon: Icons.local_hospital,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              title: AppLocalizations.of(context).service,
              value: service.name,
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              title: AppLocalizations.of(context).duration,
              value: '${service.duration} ${AppLocalizations.of(context).durationMinutes}',
              icon: Icons.schedule,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              title: AppLocalizations.of(context).price,
              value: '\$${service.price.toStringAsFixed(2)}',
              icon: Icons.attach_money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          '$title:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).selectDateTime,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: InkWell(
            onTap: _selectDateTime,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDateTime != null
                          ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} at ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                          : AppLocalizations.of(context).selectDateTimeHint,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _selectedDateTime != null
                                ? null
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).yourInformation,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).fullName,
            hintText: AppLocalizations.of(context).enterFullName,
            prefixIcon: const Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context).pleaseEnterName;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).email,
            hintText: AppLocalizations.of(context).enterEmailAddress,
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context).pleaseEnterEmail;
            }
            if (!value.contains('@')) {
              return AppLocalizations.of(context).invalidEmail;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).phoneNumber,
            hintText: AppLocalizations.of(context).enterPhoneNumber,
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context).pleaseEnterPhone;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBookingButton(
    BuildContext context,
    Clinic clinic,
    Service service,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                '${AppLocalizations.of(context).completeBooking} - \$${service.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate != null && context.mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 9))),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSelectDatetime)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<BookingProvider>();
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      provider.createBooking(
        clinicId: widget.clinicId,
        serviceId: widget.serviceId,
        dateTime: _selectedDateTime!,
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).bookingConfirmedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to customer browse
        context.go('/customer');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).bookingFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
