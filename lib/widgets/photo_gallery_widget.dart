import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/booking_provider.dart';

class PhotoGalleryWidget extends StatefulWidget {
  final List<String> photoUrls;
  final Function(String) onPhotoSelected;
  final Function() onAddPhoto;
  final Function(String) onDeletePhoto;

  const PhotoGalleryWidget({
    super.key,
    required this.photoUrls,
    required this.onPhotoSelected,
    required this.onAddPhoto,
    required this.onDeletePhoto,
  });

  @override
  State<PhotoGalleryWidget> createState() => _PhotoGalleryWidgetState();
}

class _PhotoGalleryWidgetState extends State<PhotoGalleryWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Зурагнууд',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: widget.onAddPhoto,
              icon: const Icon(Icons.add),
              label: const Text('Нэмэх'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.photoUrls.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'Оруулсан зураг байхгүй',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Дээрх "Нэмэх" товчийг дарж зураг оруулна уу',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.photoUrls.length,
            itemBuilder: (context, index) {
              final photoUrl = widget.photoUrls[index];
              return _buildPhotoItem(photoUrl, index);
            },
          ),
      ],
    );
  }

  Widget _buildPhotoItem(String photoUrl, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => widget.onPhotoSelected(photoUrl),
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showDeleteConfirmation(photoUrl, index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String photoUrl, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Зураг устгах'),
        content: const Text('Та энэ зурагыг устгахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Үгүй'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeletePhoto(photoUrl);
            },
            child: const Text(
              'Устгах',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
