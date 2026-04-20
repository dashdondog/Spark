import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class CompanyDashboardPage extends StatelessWidget {
  const CompanyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          final clinics = provider.clinics;
          final bookings = provider.bookings;
          final todayBookings = _getTodayBookings(bookings);
          final pendingBookings =
              bookings.where((b) => b.status == BookingStatus.pending).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, todayBookings.length),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildQuickActions(context),
                    const SizedBox(height: 22),
                    _buildStatsRow(context, clinics, bookings, todayBookings),
                    const SizedBox(height: 24),
                    _buildTodaySchedule(context, todayBookings, provider),
                    const SizedBox(height: 24),
                    if (pendingBookings.isNotEmpty) ...[
                      _buildPendingSection(context, pendingBookings, provider),
                      const SizedBox(height: 24),
                    ],
                    _buildClinicsSection(context, clinics),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, int todayCount) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Өглөөний мэнд';
    } else if (hour < 18) {
      greeting = 'Өдрийн мэнд';
    } else {
      greeting = 'Оройн мэнд';
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 16,
        right: 16,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/company/profile'),
                child: Consumer<ProfileProvider>(
                  builder: (context, profile, _) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        profile.initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, profile, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting 👋',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _roundIcon(
                Icons.notifications_outlined,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Мэдэгдэл байхгүй')),
                ),
                badge: true,
              ),
              const SizedBox(width: 8),
              _roundIcon(
                Icons.settings_outlined,
                onTap: () => context.push('/company/profile'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Өнөөдөр',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$todayCount захиалга төлөвлөгдсөн',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon,
      {required VoidCallback onTap, bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (badge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.add_circle_outline, 'Шинэ\nзахиалга', AppTheme.primary, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Удахгүй нэмэгдэнэ')),
        );
      }),
      (Icons.medical_services_outlined, 'Үйлчилгээ', AppTheme.accent, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Удахгүй нэмэгдэнэ')),
        );
      }),
      (Icons.bar_chart_rounded, 'Тайлан', AppTheme.warning, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Удахгүй нэмэгдэнэ')),
        );
      }),
      (Icons.people_outline_rounded, 'Үйлчлүүлэгч', AppTheme.success, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Удахгүй нэмэгдэнэ')),
        );
      }),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: a.$4,
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: a.$3.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(a.$1, color: a.$3, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  a.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────
  Widget _buildStatsRow(
    BuildContext context,
    List<Clinic> clinics,
    List<Booking> bookings,
    List<Booking> todayBookings,
  ) {
    final confirmed =
        bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final pending =
        bookings.where((b) => b.status == BookingStatus.pending).length;
    final revenue = bookings
        .where((b) => b.status == BookingStatus.confirmed)
        .length
        .toDouble() *
        50.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Тоймчилсон',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _miniStat(
                icon: Icons.pending_actions_rounded,
                label: 'Хүлээгдэж',
                value: pending.toString(),
                color: AppTheme.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _miniStat(
                icon: Icons.check_circle_outline_rounded,
                label: 'Баталгаажсан',
                value: confirmed.toString(),
                color: AppTheme.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _miniStat(
                icon: Icons.local_hospital_rounded,
                label: 'Клиник',
                value: clinics.length.toString(),
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _miniStat(
                icon: Icons.payments_outlined,
                label: 'Орлого',
                value: '\$${revenue.toStringAsFixed(0)}',
                color: const Color(0xFF7C4DFF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Today's Schedule ───────────────────────────────────────────────────
  Widget _buildTodaySchedule(
    BuildContext context,
    List<Booking> bookings,
    BookingProvider provider,
  ) {
    final sorted = [...bookings]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Өнөөдрийн хуваарь',
          onSeeAll: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Удахгүй нэмэгдэнэ')),
            );
          },
        ),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          _emptyBox(
            icon: Icons.event_available_rounded,
            message: 'Өнөөдөр захиалга алга',
          )
        else
          Column(
            children: sorted
                .take(4)
                .map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _scheduleItem(b, provider),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _scheduleItem(Booking b, BookingProvider provider) {
    final clinic = provider.getClinicById(b.clinicId);
    final service = provider.getServiceById(b.serviceId);
    final color = _statusColor(b.status);
    final timeStr =
        '${b.dateTime.hour.toString().padLeft(2, '0')}:${b.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: AppTheme.divider,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${service?.name ?? '—'} · ${clinic?.name ?? '—'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(b.status),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pending Section ────────────────────────────────────────────────────
  Widget _buildPendingSection(
    BuildContext context,
    List<Booking> pending,
    BookingProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Баталгаажуулах',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pending.length.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: pending
              .take(3)
              .map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _pendingCard(context, b, provider),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _pendingCard(
      BuildContext context, Booking b, BookingProvider provider) {
    final service = provider.getServiceById(b.serviceId);
    final dateStr =
        '${b.dateTime.day}/${b.dateTime.month} · ${b.dateTime.hour.toString().padLeft(2, '0')}:${b.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  b.customerName.isNotEmpty ? b.customerName[0] : '?',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${service?.name ?? '—'} · $dateStr',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Цуцлагдлаа')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(
                        color: AppTheme.error.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Татгалзах',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Баталгаажлаа')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Баталгаажуулах',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Clinics Section ────────────────────────────────────────────────────
  Widget _buildClinicsSection(BuildContext context, List<Clinic> clinics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Миний клиникүүд',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Удахгүй нэмэгдэнэ')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 16, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      'Нэмэх',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (clinics.isEmpty)
          _emptyBox(
            icon: Icons.local_hospital_outlined,
            message: 'Клиник нэмэгдээгүй байна',
          )
        else
          Column(
            children: clinics
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _clinicTile(context, c),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _clinicTile(BuildContext context, Clinic clinic) {
    return GestureDetector(
      onTap: () => context.push('/clinic/${clinic.id}/manage'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_hospital_rounded,
                  color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppTheme.textLight),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          clinic.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textLight),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────
  Widget _sectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'Бүгдийг',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyBox({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppTheme.textLight),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
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
                onPressed: () async {
                  Navigator.pop(ctx);
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) context.go('/role');
                },
                child: const Text('Гарах',
                    style: TextStyle(
                        color: AppTheme.error, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.error, size: 18),
            SizedBox(width: 8),
            Text(
              'Гарах',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  List<Booking> _getTodayBookings(List<Booking> bookings) {
    final now = DateTime.now();
    return bookings.where((b) {
      return b.dateTime.year == now.year &&
          b.dateTime.month == now.month &&
          b.dateTime.day == now.day;
    }).toList();
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppTheme.success;
      case BookingStatus.pending:
        return AppTheme.warning;
      case BookingStatus.cancelled:
        return AppTheme.error;
      case BookingStatus.completed:
        return AppTheme.textLight;
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Баталсан';
      case BookingStatus.pending:
        return 'Хүлээгдэж';
      case BookingStatus.cancelled:
        return 'Цуцалсан';
      case BookingStatus.completed:
        return 'Дууссан';
    }
  }
}
