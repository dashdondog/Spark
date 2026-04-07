import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_provider.dart';
import '../l10n/app_localizations.dart';

class ClinicProfilePage extends StatelessWidget {
  final String clinicId;

  const ClinicProfilePage({
    super.key,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final clinic = provider.getClinicById(clinicId);
        final services = provider.getClinicServices(clinicId);

        if (clinic == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Клиник олдсонгүй'),
            ),
            body: const Center(
              child: Text('Клиник олдсонгүй'),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, clinic),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClinicInfo(context, clinic),
                      const SizedBox(height: 24),
                      _buildServicesSection(context, services, clinic.id),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Clinic clinic) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: clinic.imageUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.local_hospital,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Add to favorites
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Таалагдсан руу нэмлээ')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Share clinic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Хуваалцах функц тун удахгүй')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildClinicInfo(BuildContext context, Clinic clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                clinic.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(width: 16),
            _buildRating(context, clinic.rating),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          clinic.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 24),
        _buildContactInfo(context, clinic),
      ],
    );
  }

  Widget _buildRating(BuildContext context, double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: rating >= 4.5
            ? Colors.green.withOpacity(0.1)
            : rating >= 4.0
                ? Colors.amber.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 18,
            color: rating >= 4.5
                ? Colors.green
                : rating >= 4.0
                    ? Colors.amber
                    : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: rating >= 4.5
                      ? Colors.green
                      : rating >= 4.0
                          ? Colors.amber
                          : Colors.orange,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Clinic clinic) {
    return Column(
      children: [
        _buildContactItem(
          context,
          icon: Icons.location_on,
          title: 'Хаяг',
          content: clinic.address,
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context,
          icon: Icons.phone,
          title: 'Утас',
          content: clinic.phone,
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context,
          icon: Icons.email,
          title: 'И-мэйл',
          content: clinic.email,
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    List<Service> services,
    String clinicId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Үйлчилгээ',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (services.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Үйлчилгээ байхгүй',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceCard(context, service, clinicId);
            },
          ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    Service service,
    String clinicId,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${service.duration} минут',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    context.go('/book/$clinicId/${service.id}');
                  },
                  child: const Text('Одоо захиалах'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
