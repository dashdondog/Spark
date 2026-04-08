import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';

class ClinicProfilePage extends StatelessWidget {
  final String clinicId;

  const ClinicProfilePage({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final clinic = provider.getClinicById(clinicId);
        final services = provider.getClinicServices(clinicId);

        if (clinic == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Олдсонгүй')),
            body: const Center(child: Text('Клиник олдсонгүй')),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: CustomScrollView(
            slivers: [
              _SliverHeader(clinic: clinic),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _ProfileCard(clinic: clinic),
                    _StatsRow(clinic: clinic),
                    _AboutSection(clinic: clinic),
                    _ContactSection(clinic: clinic),
                    _ServicesSection(services: services, clinicId: clinicId),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BookingBar(
              services: services, clinicId: clinicId),
        );
      },
    );
  }
}

// ── Sliver Header ────────────────────────────────────────────────────────────
class _SliverHeader extends StatelessWidget {
  final Clinic clinic;

  const _SliverHeader({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppTheme.primary,
      leading: GestureDetector(
        onTap: () => context.canPop() ? context.pop() : context.go('/customer'),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 22),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border_rounded,
                color: Colors.white, size: 20),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Дуртайд нэмэгдлээ')),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B75BC), Color(0xFF0D5A9A)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      clinic.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

// ── Profile Card ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final Clinic clinic;

  const _ProfileCard({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            clinic.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Эмнэлгийн төв',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < clinic.rating.floor()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: AppTheme.star,
                  size: 20,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${clinic.rating}  (128 сэтгэгдэл)',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final Clinic clinic;

  const _StatsRow({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _StatCard(
              value: '1.2k+',
              label: 'Өвчтөн',
              icon: Icons.people_outline_rounded,
              color: AppTheme.primary),
          const SizedBox(width: 12),
          _StatCard(
              value: '8+',
              label: 'Жил туршлага',
              icon: Icons.workspace_premium_outlined,
              color: const Color(0xFFFF7043)),
          const SizedBox(width: 12),
          _StatCard(
              value: '128',
              label: 'Сэтгэгдэл',
              icon: Icons.star_outline_rounded,
              color: AppTheme.star),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark),
            ),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

// ── About Section ────────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  final Clinic clinic;

  const _AboutSection({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Тухай',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Text(
              clinic.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMedium,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact Section ──────────────────────────────────────────────────────────
class _ContactSection extends StatelessWidget {
  final Clinic clinic;

  const _ContactSection({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            _ContactRow(
                icon: Icons.location_on_outlined, text: clinic.address),
            const Divider(height: 20),
            _ContactRow(icon: Icons.phone_outlined, text: clinic.phone),
            const Divider(height: 20),
            _ContactRow(icon: Icons.email_outlined, text: clinic.email),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// ── Services Section ─────────────────────────────────────────────────────────
class _ServicesSection extends StatelessWidget {
  final List<Service> services;
  final String clinicId;

  const _ServicesSection(
      {required this.services, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Үйлчилгээ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark),
              ),
              Text(
                '${services.length} боломжтой',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textLight),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (services.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(Icons.medical_services_outlined,
                      size: 40, color: AppTheme.textLight),
                  SizedBox(height: 8),
                  Text('Үйлчилгээ байхгүй байна',
                      style: TextStyle(color: AppTheme.textLight)),
                ],
              ),
            )
          else
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServiceCard(service: service, clinicId: clinicId),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final String clinicId;

  const _ServiceCard({required this.service, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.medical_services_outlined,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 12, color: AppTheme.textLight),
                    const SizedBox(width: 3),
                    Text(
                      '${service.duration} min',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${service.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => context.go('/book/$clinicId/${service.id}'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bottom Booking Bar ────────────────────────────────────────────────────────
class _BookingBar extends StatelessWidget {
  final List<Service> services;
  final String clinicId;

  const _BookingBar({required this.services, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x12000000),
              blurRadius: 24,
              offset: Offset(0, -6)),
        ],
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: services.isEmpty
              ? null
              : () => context.go('/book/$clinicId/${services.first.id}'),
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: const Text('Цаг захиалах'),
        ),
      ),
    );
  }
}
