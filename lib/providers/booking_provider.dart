import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class BookingProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  List<Clinic> _clinics = [];
  List<Service> _services = [];
  List<Booking> _bookings = [];

  List<Clinic> get clinics => List.unmodifiable(_clinics);
  List<Service> get services => List.unmodifiable(_services);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  BookingProvider() {
    _listenClinics();
    _listenServices();
    _listenBookings();
  }

  // ── Real-time listeners ───────────────────────────────────────────────────

  void _listenClinics() {
    _db.collection('clinics').snapshots().listen((snap) {
      _clinics = snap.docs.map((d) => Clinic.fromFirestore(d)).toList();
      notifyListeners();
    });
  }

  void _listenServices() {
    _db.collection('services').snapshots().listen((snap) {
      _services = snap.docs.map((d) => Service.fromFirestore(d)).toList();
      notifyListeners();
    });
  }

  void _listenBookings() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Query query = _db.collection('bookings');
    if (uid != null) {
      query = query.where('userId', isEqualTo: uid);
    }
    query.snapshots().listen((snap) {
      _bookings = snap.docs
          .map((d) => Booking.fromFirestore(d))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    final results = await Future.wait([
      _db.collection('clinics').get(),
      _db.collection('services').get(),
    ]);
    _clinics = (results[0] as QuerySnapshot)
        .docs
        .map((d) => Clinic.fromFirestore(d))
        .toList();
    _services = (results[1] as QuerySnapshot)
        .docs
        .map((d) => Service.fromFirestore(d))
        .toList();
    _isRefreshing = false;
    notifyListeners();
  }

  // ── Bookings ──────────────────────────────────────────────────────────────

  Future<void> createBooking({
    required String clinicId,
    required String serviceId,
    required DateTime dateTime,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final id = const Uuid().v4();
    await _db.collection('bookings').doc(id).set({
      'id': id,
      'clinicId': clinicId,
      'serviceId': serviceId,
      'dateTime': Timestamp.fromDate(dateTime),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'status': 'confirmed',
      'userId': uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
    });
  }

  // ── Clinics ───────────────────────────────────────────────────────────────

  Future<void> updateClinic(
    String clinicId, {
    String? name,
    String? address,
    String? phone,
    String? email,
    String? description,
    String? imageUrl,
    List<String>? photos,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (description != null) data['description'] = description;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (photos != null) data['photos'] = photos;
    if (data.isEmpty) return;
    await _db.collection('clinics').doc(clinicId).update(data);
  }

  Future<void> addClinicPhoto(String clinicId, String localPath) async {
    final file = File(localPath);
    final ext = localPath.split('.').last;
    final ref = _storage.ref('clinics/$clinicId/${const Uuid().v4()}.$ext');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final clinic = getClinicById(clinicId);
    final updated = [...(clinic?.photos ?? []), url];
    await _db.collection('clinics').doc(clinicId).update({'photos': updated});
  }

  Future<void> removeClinicPhoto(String clinicId, String photoUrl) async {
    final clinic = getClinicById(clinicId);
    if (clinic == null) return;
    final updated = clinic.photos.where((p) => p != photoUrl).toList();
    await _db.collection('clinics').doc(clinicId).update({'photos': updated});
    if (photoUrl.startsWith('https://firebasestorage')) {
      try {
        await _storage.refFromURL(photoUrl).delete();
      } catch (_) {}
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Clinic? getClinicById(String id) {
    try {
      return _clinics.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Service> getClinicServices(String clinicId) {
    final clinic = getClinicById(clinicId);
    if (clinic == null) return [];
    return _services.where((s) => clinic.services.contains(s.id)).toList();
  }

  // ── Seed initial data (run once) ──────────────────────────────────────────

  Future<void> seedInitialData() async {
    final existing = await _db.collection('clinics').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();

    final serviceIds = List.generate(10, (i) => '${i + 1}');
    final serviceData = [
      {'name': 'Ерөнхий үзлэг', 'description': 'Ерөнхий эрүүл мэндийн үзлэг', 'duration': 30, 'price': 50000.0},
      {'name': 'Шүдний үзлэг', 'description': 'Шүдний бүрэн үзлэг', 'duration': 45, 'price': 80000.0},
      {'name': 'Вакцин', 'description': 'Дархлааны үйлчилгээ', 'duration': 15, 'price': 25000.0},
      {'name': 'Физик эмчилгээ', 'description': 'Сэргээн засах эмчилгээ', 'duration': 60, 'price': 120000.0},
      {'name': 'Зүрхний үзлэг', 'description': 'Зүрхний эрүүл мэндийн үнэлгээ', 'duration': 45, 'price': 150000.0},
      {'name': 'Хүүхдийн үзлэг', 'description': 'Хүүхдийн өсөлтийн хяналт', 'duration': 30, 'price': 60000.0},
      {'name': 'Яс үений үзлэг', 'description': 'Яс, үе мөч, булчингийн үнэлгээ', 'duration': 40, 'price': 100000.0},
      {'name': 'Нүдний үзлэг', 'description': 'Нүдний бүрэн үзлэг', 'duration': 30, 'price': 70000.0},
      {'name': 'Арьс судлал', 'description': 'Арьсны үзлэг, эмчилгээ', 'duration': 30, 'price': 90000.0},
      {'name': 'Цусны шинжилгээ', 'description': 'Цогц цусны шинжилгээ', 'duration': 20, 'price': 45000.0},
    ];

    for (int i = 0; i < serviceData.length; i++) {
      final ref = _db.collection('services').doc(serviceIds[i]);
      batch.set(ref, {'id': serviceIds[i], ...serviceData[i]});
    }

    final clinicData = [
      {'name': 'City Medical Center', 'address': 'Сүхбаатар дүүрэг, 1-р хороо', 'phone': '+976 7700 1111', 'email': 'info@citymedical.mn', 'rating': 4.5, 'description': 'Өндөр чанарын эрүүл мэндийн үйлчилгээ үзүүлдэг цогц эмнэлэг.', 'services': ['1', '2', '3'], 'photos': ['https://picsum.photos/seed/clinic1a/600/400']},
      {'name': 'Family Health Clinic', 'address': 'Баянзүрх дүүрэг, 3-р хороо', 'phone': '+976 7700 2222', 'email': 'info@familyhealth.mn', 'rating': 4.8, 'description': 'Гэр бүлийн итгэмжлэгдсэн эмнэлэг.', 'services': ['1', '4', '6'], 'photos': ['https://picsum.photos/seed/clinic2a/600/400']},
      {'name': 'Bright Smile Dental', 'address': 'Чингэлтэй дүүрэг, 2-р хороо', 'phone': '+976 7700 3333', 'email': 'info@brightsmile.mn', 'rating': 4.7, 'description': 'Орчин үеийн шүдний эмнэлэг.', 'services': ['2', '10'], 'photos': ['https://picsum.photos/seed/clinic3a/600/400']},
      {'name': 'Heart & Vascular Institute', 'address': 'Хан-Уул дүүрэг, 5-р хороо', 'phone': '+976 7700 4444', 'email': 'info@heartinstitute.mn', 'rating': 4.9, 'description': 'Зүрх судасны тэргүүлэх төв.', 'services': ['5', '1', '10'], 'photos': []},
      {"name": "Children's Health Center", 'address': 'Налайх дүүрэг', 'phone': '+976 7700 5555', 'email': 'info@childrens.mn', 'rating': 4.6, 'description': 'Хүүхдийн мэргэшсэн эмнэлэг.', 'services': ['6', '3', '1'], 'photos': []},
      {'name': 'Ortho & Sports Medicine', 'address': 'Сонгинохайрхан дүүрэг', 'phone': '+976 7700 6666', 'email': 'info@orthosports.mn', 'rating': 4.4, 'description': 'Яс үе мөчний болон спортын эмнэлэг.', 'services': ['7', '4'], 'photos': []},
      {'name': 'Vision Care Eye Clinic', 'address': 'Баянгол дүүрэг, 4-р хороо', 'phone': '+976 7700 7777', 'email': 'info@visioncare.mn', 'rating': 4.5, 'description': 'Нүдний иж бүрэн эмнэлэг.', 'services': ['8', '10'], 'photos': []},
      {'name': 'Skin & Wellness Clinic', 'address': 'Сүхбаатар дүүрэг, 8-р хороо', 'phone': '+976 7700 8888', 'email': 'info@skinwellness.mn', 'rating': 4.3, 'description': 'Арьс судлал ба сайн мэдрэмжийн клиник.', 'services': ['9', '1'], 'photos': []},
    ];

    for (int i = 0; i < clinicData.length; i++) {
      final id = '${i + 1}';
      final ref = _db.collection('clinics').doc(id);
      batch.set(ref, {'id': id, 'imageUrl': '', ...clinicData[i]});
    }

    await batch.commit();
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class Booking {
  final String id;
  final String clinicId;
  final String serviceId;
  final DateTime dateTime;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.clinicId,
    required this.serviceId,
    required this.dateTime,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.status,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Booking(
      id: d['id'] ?? doc.id,
      clinicId: d['clinicId'] ?? '',
      serviceId: d['serviceId'] ?? '',
      dateTime: (d['dateTime'] as Timestamp).toDate(),
      customerName: d['customerName'] ?? '',
      customerEmail: d['customerEmail'] ?? '',
      customerPhone: d['customerPhone'] ?? '',
      status: _statusFromString(d['status']),
    );
  }

  static BookingStatus _statusFromString(String? s) {
    switch (s) {
      case 'confirmed': return BookingStatus.confirmed;
      case 'cancelled': return BookingStatus.cancelled;
      case 'completed': return BookingStatus.completed;
      default: return BookingStatus.pending;
    }
  }
}

enum BookingStatus { pending, confirmed, cancelled, completed }

class Clinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final double rating;
  final String imageUrl;
  final String description;
  final List<String> services;
  final List<String> photos;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.rating,
    required this.imageUrl,
    required this.description,
    required this.services,
    this.photos = const [],
  });

  factory Clinic.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Clinic(
      id: d['id'] ?? doc.id,
      name: d['name'] ?? '',
      address: d['address'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: d['imageUrl'] ?? '',
      description: d['description'] ?? '',
      services: List<String>.from(d['services'] ?? []),
      photos: List<String>.from(d['photos'] ?? []),
    );
  }
}

class Service {
  final String id;
  final String name;
  final String description;
  final int duration;
  final double price;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
  });

  factory Service.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Service(
      id: d['id'] ?? doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      duration: (d['duration'] as num?)?.toInt() ?? 30,
      price: (d['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
