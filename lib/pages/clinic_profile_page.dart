import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
              _SliverPhotoHeader(clinic: clinic),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _ProfileCard(clinic: clinic),
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

// ── Sliver Photo Header ───────────────────────────────────────────────────────
class _SliverPhotoHeader extends StatefulWidget {
  final Clinic clinic;
  const _SliverPhotoHeader({required this.clinic});

  @override
  State<_SliverPhotoHeader> createState() => _SliverPhotoHeaderState();
}

class _SliverPhotoHeaderState extends State<_SliverPhotoHeader> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showPicker() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primary),
              title: const Text('Камераас авах'),
              onTap: () { Navigator.pop(ctx); _pick(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primary),
              title: const Text('Галерейгаас сонгох'),
              onTap: () { Navigator.pop(ctx); _pick(ImageSource.gallery); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source, maxWidth: 1200, imageQuality: 85,
    );
    if (image != null && mounted) {
      context.read<BookingProvider>().addClinicPhoto(widget.clinic.id, image.path);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            widget.clinic.photos.length, // new last index
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _buildSlide(String photo) {
    final isLocal = !photo.startsWith('http');
    if (isLocal) {
      return Image.file(File(photo), fit: BoxFit.cover, width: double.infinity);
    }
    return CachedNetworkImage(
      imageUrl: photo,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => Container(color: const Color(0xFF1B75BC)),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFF1B75BC),
        child: const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.clinic.photos;
    final hasPhotos = photos.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.primary,
      // hide default leading — we overlay our own button
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ── Photo PageView or gradient fallback ──
            if (hasPhotos)
              PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: photos.length,
                itemBuilder: (_, i) => _buildSlide(photos[i]),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B75BC), Color(0xFF0D5A9A)],
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.clinic.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // ── Dark gradient top (nav buttons) ──
            Positioned(
              top: 0, left: 0, right: 0,
              height: 100,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x88000000), Colors.transparent],
                  ),
                ),
              ),
            ),

            // ── Dark gradient bottom (dots) ──
            if (hasPhotos)
              Positioned(
                bottom: 0, left: 0, right: 0,
                height: 60,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0x88000000), Colors.transparent],
                    ),
                  ),
                ),
              ),

            // ── Dots indicator ──
            if (hasPhotos)
              Positioned(
                bottom: 12, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(photos.length, (i) {
                    final active = _currentPage == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),

            // ── Nav buttons row ──
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              left: 8, right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/customer'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textDark, size: 18),
                    ),
                  ),
                  // Add photo + favourite
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showPicker,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_photo_alternate_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Дуртайд нэмэгдлээ')),
                        ),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_border_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

// ── Photo Slider ─────────────────────────────────────────────────────────────
class _PhotoSlider extends StatefulWidget {
  final Clinic clinic;
  const _PhotoSlider({required this.clinic});

  @override
  State<_PhotoSlider> createState() => _PhotoSliderState();
}

class _PhotoSliderState extends State<_PhotoSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showPicker() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primary),
              title: const Text('Камераас авах'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primary),
              title: const Text('Галерейгаас сонгох'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      context.read<BookingProvider>().addClinicPhoto(widget.clinic.id, image.path);
      // Jump to last slide after adding
      final newCount = widget.clinic.photos.length + 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            newCount - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _buildImage(String photo) {
    final isLocal = !photo.startsWith('http');
    if (isLocal) {
      return Image.file(File(photo), fit: BoxFit.cover, width: double.infinity);
    }
    return CachedNetworkImage(
      imageUrl: photo,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.clinic.photos;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Зурагнууд${photos.isNotEmpty ? '  (${photos.length})' : ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              GestureDetector(
                onTap: _showPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 16, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text('Нэмэх',
                          style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (photos.isEmpty)
            GestureDetector(
              onTap: _showPicker,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 44, color: AppTheme.textLight),
                    SizedBox(height: 10),
                    Text('Зураг нэмэх',
                        style: TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 210,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: photos.length,
                      itemBuilder: (_, index) => _buildImage(photos[index]),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(photos.length, (i) {
                    final active = _currentPage == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? AppTheme.primary : AppTheme.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
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
