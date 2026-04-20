import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
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
    {
      'icon': Icons.local_hospital_rounded,
      'label': 'Ерөнхий',
      'color': Color(0xFF1B75BC),
    },
    {
      'icon': Icons.medical_services_rounded,
      'emoji': '🦷',
      'label': 'Шүд',
      'color': Color(0xFFFF7043),
    },
    {'icon': Icons.favorite_rounded, 'label': 'Зүрх', 'color': Color(0xFFE91E63)},
    {
      'icon': Icons.accessibility_new_rounded,
      'label': 'Яс',
      'color': Color(0xFF4CAF50),
    },
    {'icon': Icons.child_care_rounded, 'label': 'Хүүхэд', 'color': Color(0xFF9C27B0)},
    {'icon': Icons.hearing_rounded, 'label': 'ЧИХ', 'color': Color(0xFF00BFA5)},
    {'icon': Icons.remove_red_eye_rounded, 'label': 'Нүд', 'color': Color(0xFF3F51B5)},
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
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => context.read<BookingProvider>().refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            if (!searching) ...[
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Шилдэг клиникүүд',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _AllClinicsPage()),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildTopDoctors()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Ойролцоо клиникүүд',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _AllClinicsPage()),
                  ),
                ),
              ),
            ] else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Text(
                    '"$_searchQuery" — хайлтын үр дүн',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            _buildClinicList(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
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
          // Refresh button
          Consumer<BookingProvider>(
            builder: (context, provider, _) => GestureDetector(
              onTap: provider.isRefreshing ? null : () => provider.refresh(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: provider.isRefreshing
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Notification bell
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _NotificationsPage(),
              ),
            ),
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
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primary,
                    size: 22,
                  ),
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
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final name = auth.displayName ?? auth.email ?? '?';
              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
              return Container(
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
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              );
            },
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
            hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTheme.textLight,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.textLight,
                      size: 18,
                    ),
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
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
          final label = cat['label'] as String;
          final emoji = cat['emoji'] as String?;
          final iconData = cat['icon'] as IconData;
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _CategoryPage(
                  label: label,
                  icon: iconData,
                  emoji: emoji,
                  color: color,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: emoji != null
                        ? Colors.white
                        : color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: emoji != null
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: emoji != null
                      ? Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 28),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Icon(iconData, color: color, size: 26),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
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
          child: Text(
            clinic.name[0],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          child: Text(
            clinic.name[0],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                onTap: () => context.push('/clinic/${clinic.id}'),
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
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppTheme.star,
                                    size: 13,
                                  ),
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
                                  horizontal: 14,
                                  vertical: 5,
                                ),
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
          final matchesSearch =
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.address.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesSearch;
        }).toList();

        if (clinics.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Клиник олдсонгүй',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
                onTap: () => context.push('/clinic/${clinics[index].id}'),
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
                  onTap: () => context.push('/clinic/${clinic.id}'),
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
        child: const Icon(
          Icons.local_hospital_rounded,
          color: AppTheme.primary,
          size: 32,
        ),
      );
    }
    if (!photo.startsWith('http')) {
      return Image.file(File(photo), fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: photo,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: AppTheme.primaryLight),
      errorWidget: (_, __, ___) => Container(
        color: AppTheme.primaryLight,
        child: const Icon(
          Icons.local_hospital_rounded,
          color: AppTheme.primary,
          size: 32,
        ),
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
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          clinic.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
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
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: AppTheme.star,
                            ),
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
                          horizontal: 8,
                          vertical: 3,
                        ),
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
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
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
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      size: 46,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Захиалга байхгүй байна',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
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

class _AppointmentCard extends StatefulWidget {
  final Booking booking;
  final String clinicName;
  final String serviceName;

  const _AppointmentCard({
    required this.booking,
    required this.clinicName,
    required this.serviceName,
  });

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  late final _timer = Stream.periodic(const Duration(seconds: 1));
  late final _sub = _timer.listen((_) { if (mounted) setState(() {}); });

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  String _countdown() {
    final now = DateTime.now();
    final diff = widget.booking.dateTime.difference(now);
    if (diff.isNegative) return 'Дууссан';
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final mins = diff.inMinutes % 60;
    final secs = diff.inSeconds % 60;
    if (days > 0) return '$days өдөр $hours цаг $mins мин';
    if (hours > 0) return '$hours цаг $mins мин $secs сек';
    return '$mins мин $secs сек';
  }

  static const _statusColors = {
    BookingStatus.confirmed: AppTheme.success,
    BookingStatus.pending: AppTheme.warning,
    BookingStatus.cancelled: AppTheme.error,
    BookingStatus.completed: AppTheme.textLight,
  };
  static const _statusLabels = {
    BookingStatus.confirmed: 'Баталгаажсан',
    BookingStatus.pending: 'Хүлээгдэж буй',
    BookingStatus.cancelled: 'Цуцлагдсан',
    BookingStatus.completed: 'Дууссан',
  };

  @override
  Widget build(BuildContext context) {
    final dt = widget.booking.dateTime;
    final dateStr =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final statusColor = _statusColors[widget.booking.status]!;
    final isPast = widget.booking.dateTime.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.clinicName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.serviceName,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabels[widget.booking.status]!,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: AppTheme.divider),

          // ── Date row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppTheme.textLight),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time_rounded,
                    size: 14, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark),
                ),
                const Spacer(),
                _chip(Icons.person_outline_rounded,
                    widget.booking.customerName),
              ],
            ),
          ),

          // ── Countdown timer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isPast
                    ? AppTheme.textLight.withValues(alpha: 0.08)
                    : AppTheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPast
                        ? Icons.check_circle_outline_rounded
                        : Icons.timer_outlined,
                    size: 14,
                    color: isPast ? AppTheme.textLight : AppTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _countdown(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isPast ? AppTheme.textLight : AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textLight),
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

class _MessagesTab extends StatefulWidget {
  const _MessagesTab();

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
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

  final _mapController = MapController();
  LatLng? _userLocation;
  double? _accuracy;
  bool _isLoadingLocation = true;
  bool _isRefreshingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation({bool isRefresh = false}) async {
    if (isRefresh) setState(() => _isRefreshingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Байршлын үйлчилгээ идэвхгүй байна';
          _isLoadingLocation = false;
          _isRefreshingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Байршлын зөвшөөрөл татгалзлаа';
            _isLoadingLocation = false;
            _isRefreshingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Байршлын зөвшөөрөл бүрмөсөн татгалзлаа';
          _isLoadingLocation = false;
          _isRefreshingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final loc = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = loc;
        _accuracy = position.accuracy;
        _isLoadingLocation = false;
        _isRefreshingLocation = false;
        _locationError = null;
      });

      if (isRefresh) {
        _mapController.move(loc, _mapController.camera.zoom);
      }
    } catch (e) {
      setState(() {
        _locationError = 'Байршил авахад алдаа гарлаа';
        _isLoadingLocation = false;
        _isRefreshingLocation = false;
      });
    }
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15);
    } else {
      _getUserLocation(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Газрын зураг'),
        automaticallyImplyLeading: false,
        actions: [
          if (_locationError != null)
            Tooltip(
              message: _locationError ?? '',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(Icons.location_off_rounded, color: Colors.orange[700]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRefreshingLocation ? null : _centerOnUser,
        backgroundColor: Colors.white,
        elevation: 4,
        child: _isRefreshingLocation
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary,
                ),
              )
            : Icon(
                _userLocation != null
                    ? Icons.my_location_rounded
                    : Icons.location_searching_rounded,
                color: AppTheme.primary,
              ),
      ),
      body: _isLoadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text(
                    'Байршил тодорхойлж байна...',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                  ),
                ],
              ),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation ?? const LatLng(47.9077, 106.8832),
                initialZoom: _userLocation != null ? 15 : 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.clinic_connect_flutter',
                ),
                // Accuracy radius circle
                if (_userLocation != null && _accuracy != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _userLocation!,
                        radius: _accuracy!,
                        useRadiusInMeter: true,
                        color: Colors.blue.withValues(alpha: 0.12),
                        borderColor: Colors.blue.withValues(alpha: 0.4),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // User location marker
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 72,
                        height: 72,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Clinic markers
                    ..._clinicPoints.map(
                      (e) => Marker(
                        point: e.$2,
                        width: 160,
                        height: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
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
                    ),
                  ],
                ),
                // "Та энд" label overlay
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLocation!,
                        width: 60,
                        height: 90,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.35),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Та энд',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
    final auth = context.watch<AuthProvider>();
    final name = auth.displayName?.isNotEmpty == true
        ? auth.displayName!
        : auth.email ?? 'Хэрэглэгч';
    final email = auth.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, name, email, initial),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _menuItem(
                    context,
                    Icons.person_outline_rounded,
                    'Хувийн мэдээлэл',
                    const Color(0xFF1B75BC),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _ProfileEditPage(),
                      ),
                    ),
                  ),
                  _menuItem(
                    context,
                    Icons.calendar_today_outlined,
                    'Миний захиалгууд',
                    const Color(0xFF00BFA5),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _MyBookingsPage(),
                      ),
                    ),
                  ),
                  _menuItem(
                    context,
                    Icons.notifications_outlined,
                    'Мэдэгдэл',
                    const Color(0xFFFF7043),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _NotificationsPage(),
                      ),
                    ),
                  ),
                  _menuItem(
                    context,
                    Icons.help_outline_rounded,
                    'Тусламж',
                    const Color(0xFF607D8B),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const _HelpPage()),
                    ),
                  ),
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

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String email,
    String initial,
  ) {
    final bookings = context.watch<BookingProvider>().bookings;
    final total = bookings.length;
    final upcoming = bookings
        .where((b) =>
            b.dateTime.isAfter(DateTime.now()) &&
            b.status != BookingStatus.cancelled)
        .length;

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
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statBadge('$total', 'Захиалга'),
              Container(
                width: 1,
                height: 28,
                color: AppTheme.divider,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _statBadge('$upcoming', 'Удахгүй'),
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
            color: AppTheme.textDark,
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Гарах уу?',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: const Text('Та системээс гарахдаа итгэлтэй байна уу?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Үгүй',
                  style: TextStyle(color: AppTheme.textMedium),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) context.go('/role');
                },
                child: const Text(
                  'Гарах',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textLight,
          size: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}

// ── Profile Edit Page ─────────────────────────────────────────────────────────
class _ProfileEditPage extends StatefulWidget {
  const _ProfileEditPage();
  @override
  State<_ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<_ProfileEditPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(text: auth.displayName ?? '');
    _emailCtrl = TextEditingController(text: auth.email ?? '');
    _phoneCtrl = TextEditingController(
      text: auth.currentUser?.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().currentUser
          ?.updateDisplayName(_nameCtrl.text.trim());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Мэдээлэл хадгалагдлаа'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Хадгалахад алдаа гарлаа'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text[0].toUpperCase()
        : (_emailCtrl.text.isNotEmpty ? _emailCtrl.text[0].toUpperCase() : '?');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Хувийн мэдээлэл'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Нэр',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              readOnly: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'И-мэйл',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: const Tooltip(
                  message: 'И-мэйл өөрчлөх боломжгүй',
                  child: Icon(Icons.lock_outline_rounded,
                      size: 16, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Утас',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Хадгалах'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── My Bookings Page ──────────────────────────────────────────────────────────
class _MyBookingsPage extends StatelessWidget {
  const _MyBookingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Миний захиалгууд'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          final bookings = provider.bookings;
          if (bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Захиалга байхгүй байна',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Анхны захиалгаа хий',
                    style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (_, i) {
              final b = bookings[i];
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

// ── Notifications Page ────────────────────────────────────────────────────────
class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Мэдэгдэл'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: AppTheme.primaryLight,
              child: Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Мэдэгдэл байхгүй байна',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Шинэ мэдэгдэл ирэхэд энд харагдана',
              style: TextStyle(fontSize: 13, color: AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Help Page ─────────────────────────────────────────────────────────────────
class _HelpPage extends StatelessWidget {
  const _HelpPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Тусламж'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          _helpCard(
            Icons.phone_outlined,
            'Утас',
            '+976 7700 0000',
            const Color(0xFF1B75BC),
          ),
          _helpCard(
            Icons.email_outlined,
            'И-мэйл',
            'support@clinicbook.mn',
            const Color(0xFF00BFA5),
          ),
          _helpCard(
            Icons.access_time_outlined,
            'Ажлын цаг',
            'Да-Ба: 09:00-18:00',
            const Color(0xFFFF7043),
          ),
          _helpCard(
            Icons.location_on_outlined,
            'Хаяг',
            'Улаанбаатар, Монгол',
            const Color(0xFF7C4DFF),
          ),
        ],
      ),
    );
  }

  Widget _helpCard(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Category Page ─────────────────────────────────────────────────────────────
class _CategoryPage extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? emoji;
  final Color color;

  const _CategoryPage({
    required this.label,
    required this.icon,
    this.emoji,
    required this.color,
  });

  // null = бүх клиник (Ерөнхий)
  static const Map<String, List<String>?> _keywords = {
    'Ерөнхий': null,
    'Шүд':     ['шүд', 'dental', 'smile', 'bright'],
    'Зүрх':    ['зүрх', 'heart', 'cardio', 'vascular'],
    'Яс':      ['яс', 'ortho', 'bone', 'sports'],
    'Хүүхэд':  ['хүүхэд', 'child', 'pediatr', "children"],
    'ЧИХ':     ['чих', 'ear', 'хамар', 'хоолой', 'ent'],
    'Нүд':     ['нүд', 'eye', 'vision', 'харалт', 'care'],
  };

  bool _matches(Clinic clinic) {
    final keys = _keywords[label];
    if (keys == null) return true;
    final haystack = [
      clinic.name,
      clinic.address,
      clinic.description,
    ].join(' ').toLowerCase();
    return keys.any((k) => haystack.contains(k));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          final clinics = provider.clinics.where(_matches).toList();
          return RefreshIndicator(
            color: color,
            onRefresh: () => provider.refresh(),
            child: CustomScrollView(
              slivers: [
                // ── Colored header ──
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 140,
                  backgroundColor: color,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            color.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: emoji != null
                                  ? Center(
                                      child: Text(
                                        emoji!,
                                        style: const TextStyle(fontSize: 28),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : Icon(icon, color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    title: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                  ),
                ),

                // ── Subtitle / count ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                    child: provider.isRefreshing
                        ? const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '${clinics.length} клиник олдлоо',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),

                // ── Empty state ──
                if (clinics.isEmpty && !provider.isRefreshing)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: emoji != null
                                ? Center(
                                    child: Text(
                                      emoji!,
                                      style: const TextStyle(fontSize: 36),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Icon(icon, color: color, size: 36),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$label чиглэлийн клиник олдсонгүй',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Clinic list ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ClinicListCard(
                          clinic: clinics[index],
                          onTap: () =>
                              context.push('/clinic/${clinics[index].id}'),
                        ),
                      ),
                      childCount: clinics.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
