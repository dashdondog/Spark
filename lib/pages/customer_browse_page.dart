import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/booking_provider.dart';
import '../theme/app_theme.dart';

class CustomerBrowsePage extends StatefulWidget {
  const CustomerBrowsePage({super.key});

  @override
  State<CustomerBrowsePage> createState() => _CustomerBrowsePageState();
}

class _CustomerBrowsePageState extends State<CustomerBrowsePage> {
  int _currentIndex = 0;

  final _tabs = const [
    _HomeTab(),
    _AppointmentsTab(),
    _MessagesTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Нүүр',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Захиалга',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Газрын зураг',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Профайл',
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// HOME TAB
// ────────────────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, dynamic>> _categories = [
    {'icon': Icons.local_hospital, 'label': 'Ерөнхий', 'color': Color(0xFF1B75BC)},
    {'icon': Icons.medical_services, 'label': 'Шүдний', 'color': Color(0xFFFF7043)},
    {'icon': Icons.favorite, 'label': 'Зүрх', 'color': Color(0xFFE91E63)},
    {'icon': Icons.accessibility_new, 'label': 'Яс', 'color': Color(0xFF4CAF50)},
    {'icon': Icons.child_care, 'label': 'Хүүхэд', 'color': Color(0xFF9C27B0)},
    {'icon': Icons.hearing, 'label': 'ХЧЧ', 'color': Color(0xFF00BFA5)},
    {'icon': Icons.remove_red_eye, 'label': 'Нүд', 'color': Color(0xFF3F51B5)},
    {'icon': Icons.more_horiz, 'label': 'Бусад', 'color': Color(0xFF607D8B)},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searching = _searchQuery.isNotEmpty;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          if (!searching) ...[
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildSectionHeader(
              'Шилдэг клиникүүд',
              onSeeAll: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const _AllClinicsPage())),
            )),
            SliverToBoxAdapter(child: _buildTopDoctors()),
            SliverToBoxAdapter(child: _buildSectionHeader(
              'Ойролцоо клиникүүд',
              onSeeAll: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const _AllClinicsPage())),
            )),
          ] else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                  '"$_searchQuery" — хайлтын үр дүн',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          _buildClinicList(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 18,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Өглөөний мэнд 👋',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Эрүүл мэндийн шийдлээ ол',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: AppTheme.primary, size: 22),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Center(
              child: Text(
                'J',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: 'Эмч, клиник, үйлчилгээ хайх...',
            hintStyle:
                const TextStyle(color: AppTheme.textLight, fontSize: 14),
            prefixIcon:
                const Icon(Icons.search_rounded, color: AppTheme.textLight),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textLight, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Promo Banners ────────────────────────────────────────────────────────
  // ── Section Header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Бүгдийг харах',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Grid ────────────────────────────────────────────────────────
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.88,
          crossAxisSpacing: 10,
          mainAxisSpacing: 6,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final color = cat['color'] as Color;
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha:0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  cat['label'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Top Rated Horizontal Scroll ──────────────────────────────────────────
  Widget _buildCarouselThumb(Clinic clinic) {
    final photo = clinic.photos.isNotEmpty ? clinic.photos.first : null;
    if (photo == null) {
      return Container(
        color: AppTheme.primary,
        child: Center(
          child: Text(clinic.name[0],
              style: const TextStyle(
                  color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ),
      );
    }
    final isLocal = !photo.startsWith('http');
    if (isLocal) return Image.file(File(photo), fit: BoxFit.cover);
    return CachedNetworkImage(
      imageUrl: photo,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: AppTheme.primaryLight),
      errorWidget: (_, __, ___) => Container(
        color: AppTheme.primary,
        child: Center(
          child: Text(clinic.name[0],
              style: const TextStyle(
                  color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildTopDoctors() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final clinics = provider.clinics;
        return SizedBox(
          height: 224,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: clinics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return GestureDetector(
                onTap: () => context.go('/clinic/${clinic.id}'),
                child: Container(
                  width: 148,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 110,
                          child: _buildCarouselThumb(clinic),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                          child: Column(
                            children: [
                              Text(
                                clinic.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppTheme.star, size: 13),
                                  const SizedBox(width: 3),
                                  Text(
                                    clinic.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Захиалах',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Clinic List ──────────────────────────────────────────────────────────
  Widget _buildClinicList() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final clinics = provider.clinics.where((c) {
          return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.address.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (clinics.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'Клиник олдсонгүй',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _ClinicListCard(
                clinic: clinics[index],
                onTap: () => context.go('/clinic/${clinics[index].id}'),
              ),
            ),
            childCount: clinics.length,
          ),
        );
      },
    );
  }
}

// ── All Clinics Page ──────────────────────────────────────────────────────────
class _AllClinicsPage extends StatelessWidget {
  const _AllClinicsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Бүх клиникүүд'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          final clinics = provider.clinics;
          if (clinics.isEmpty) {
            return const Center(child: Text('Клиник байхгүй байна'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ClinicListCard(
                  clinic: clinic,
                  onTap: () => context.go('/clinic/${clinic.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Clinic List Card ──────────────────────────────────────────────────────────
class _ClinicListCard extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback onTap;

  const _ClinicListCard({required this.clinic, required this.onTap});

  Widget _thumb() {
    final photo = clinic.photos.isNotEmpty ? clinic.photos.first : null;
    if (photo == null) {
      return Container(
        color: AppTheme.primaryLight,
        child: const Icon(Icons.local_hospital_rounded,
            color: AppTheme.primary, size: 32),
      );
    }
    if (!photo.startsWith('http')) {
      return Image.file(File(photo), fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: photo,
      fit: BoxFit.cover,
      placeholder: (_, __) =>
          Container(color: AppTheme.primaryLight),
      errorWidget: (_, __, ___) => Container(
        color: AppTheme.primaryLight,
        child: const Icon(Icons.local_hospital_rounded,
            color: AppTheme.primary, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(width: 72, height: 72, child: _thumb()),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppTheme.textLight),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          clinic.address,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: AppTheme.star),
                            const SizedBox(width: 3),
                            Text(
                              clinic.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF856404),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text(
                          'Боломжтой',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// APPOINTMENTS TAB
// ────────────────────────────────────────────────────────────────────────────

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Миний захиалгууд'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          final bookings = provider.bookings;
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_today_outlined,
                        size: 46, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Захиалга байхгүй байна',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Анхны захиалгаа хий',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final clinic = provider.getClinicById(b.clinicId);
              final service = provider.getServiceById(b.serviceId);
              return _AppointmentCard(
                booking: b,
                clinicName: clinic?.name ?? 'Unknown',
                serviceName: service?.name ?? 'Unknown',
              );
            },
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Booking booking;
  final String clinicName;
  final String serviceName;

  const _AppointmentCard({
    required this.booking,
    required this.clinicName,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      BookingStatus.confirmed: AppTheme.success,
      BookingStatus.pending: AppTheme.warning,
      BookingStatus.cancelled: AppTheme.error,
      BookingStatus.completed: AppTheme.textLight,
    };
    final statusLabels = {
      BookingStatus.confirmed: 'Баталгаажсан',
      BookingStatus.pending: 'Хүлээгдэж буй',
      BookingStatus.cancelled: 'Цуцлагдсан',
      BookingStatus.completed: 'Дууссан',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  clinicName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColors[booking.status]!.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabels[booking.status]!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColors[booking.status],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppTheme.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(Icons.medical_services_outlined, serviceName),
              const SizedBox(width: 14),
              _chip(
                Icons.calendar_today_outlined,
                '${booking.dateTime.day}/${booking.dateTime.month}/${booking.dateTime.year}',
              ),
            ],
          ),
          const SizedBox(height: 6),
          _chip(Icons.person_outline_rounded, booking.customerName),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textLight),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// MAP TAB
// ────────────────────────────────────────────────────────────────────────────

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  // Clinic mock coordinates near Ulaanbaatar
  static const List<(String, LatLng)> _clinicPoints = [
    ('City Medical Center', LatLng(47.9120, 106.8880)),
    ('Family Health Clinic', LatLng(47.9050, 106.8750)),
    ('Bright Smile Dental', LatLng(47.9200, 106.9050)),
    ('Heart & Vascular Institute', LatLng(47.8980, 106.8650)),
    ("Children's Health Center", LatLng(47.9300, 106.8920)),
    ('Ortho & Sports Medicine', LatLng(47.9010, 106.9150)),
    ('Vision Care Eye Clinic', LatLng(47.9170, 106.8600)),
    ('Skin & Wellness Clinic', LatLng(47.9080, 106.8980)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Газрын зураг'),
        automaticallyImplyLeading: false,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(47.9077, 106.8832),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.clinic_connect_flutter',
          ),
          MarkerLayer(
            markers: _clinicPoints
                .map(
                  (e) => Marker(
                    point: e.$2,
                    width: 160,
                    height: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            e.$1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// PROFILE TAB
// ────────────────────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProfileHeader(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _menuItem(context, Icons.person_outline_rounded,
                      'Хувийн мэдээлэл', const Color(0xFF1B75BC)),
                  _menuItem(context, Icons.calendar_today_outlined,
                      'Миний захиалгууд', const Color(0xFF00BFA5)),
                  _menuItem(context, Icons.favorite_outline_rounded,
                      'Дуртай эмчид', const Color(0xFFE91E63)),
                  _menuItem(context, Icons.payment_outlined, 'Төлбөрийн арга',
                      const Color(0xFF7C4DFF)),
                  _menuItem(context, Icons.notifications_outlined,
                      'Мэдэгдэл', const Color(0xFFFF7043)),
                  _menuItem(context, Icons.help_outline_rounded,
                      'Тусламж', const Color(0xFF607D8B)),
                  const SizedBox(height: 16),
                  _logoutButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 32,
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha:0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'J',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'John Doe',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'john@example.com',
            style: TextStyle(fontSize: 13, color: AppTheme.textLight),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statBadge('12', 'Захиалга'),
              Container(
                  width: 1, height: 28, color: AppTheme.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 20)),
              _statBadge('3', 'Удахгүй'),
              Container(
                  width: 1, height: 28, color: AppTheme.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 20)),
              _statBadge('5', 'Дуртай'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
        ),
      ],
    );
  }

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Гарах уу?', style: TextStyle(fontWeight: FontWeight.w800)),
            content: const Text('Та системээс гарахдаа итгэлтэй байна уу?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Үгүй', style: TextStyle(color: AppTheme.textMedium)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/');
                },
                child: const Text('Гарах', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
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

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String label,
    Color iconColor, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha:0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isLogout ? AppTheme.error : AppTheme.textDark,
          ),
        ),
        trailing: isLogout
            ? null
            : const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textLight, size: 20),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () {},
      ),
    );
  }
}
