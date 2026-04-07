import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];
  final List<Clinic> _clinics = [];
  final List<Service> _services = [];
  
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Clinic> get clinics => List.unmodifiable(_clinics);
  List<Service> get services => List.unmodifiable(_services);

  // Mock data for demonstration
  BookingProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock clinics
    _clinics.addAll([
      Clinic(
        id: '1',
        name: 'Хотын Анагаах Ухааны Төв',
        address: '123 Main St, City, State 12345',
        phone: '+1 (555) 123-4567',
        email: 'info@citymedical.com',
        rating: 4.5,
        imageUrl: 'https://via.placeholder.com/300x200/3B82F6/FFFFFF?text=City+Medical',
        description: 'Чанартай эрүүл мэндийн үйлчилгээ үзүүлэх нэгдсэн анагаах ухааны төв.',
        services: ['1', '2', '3'],
      ),
      Clinic(
        id: '2',
        name: 'Гэр бүлийн Эрүүл Мэндийн Клиник',
        address: '456 Oak Ave, Town, State 67890',
        phone: '+1 (555) 987-6543',
        email: 'contact@familyhealth.com',
        rating: 4.8,
        imageUrl: 'https://via.placeholder.com/300x200/10B981/FFFFFF?text=Family+Health',
        description: 'Таны итгэлт гэр бүлийн эрүүл мэндийн үйлчилгээ үзүүлэгч.',
        services: ['1', '4'],
      ),
    ]);

    // Mock services
    _services.addAll([
      Service(
        id: '1',
        name: 'Ерөнхий зөвлөгөө',
        description: 'Эрүүл мэндийн ерөнхий үзлэг ба зөвлөгөө',
        duration: 30,
        price: 50.0,
      ),
      Service(
        id: '2',
        name: 'Шүдний үзлэг',
        description: 'Шүдний бүрэн үзлэг',
        duration: 45,
        price: 80.0,
      ),
      Service(
        id: '3',
        name: 'Тариа',
        description: 'Тогтмол дархлаажуулалтын үйлчилгээ',
        duration: 15,
        price: 25.0,
      ),
      Service(
        id: '4',
        name: 'Физикийн эмчилгээ',
        description: 'Сэргээн засах ба эмчилгээний суулгууд',
        duration: 60,
        price: 120.0,
      ),
    ]);
  }

  void createBooking({
    required String clinicId,
    required String serviceId,
    required DateTime dateTime,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) {
    final booking = Booking(
      id: const Uuid().v4(),
      clinicId: clinicId,
      serviceId: serviceId,
      dateTime: dateTime,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      status: BookingStatus.confirmed,
    );

    _bookings.add(booking);
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
  }

  Clinic? getClinicById(String id) {
    try {
      return _clinics.firstWhere((clinic) => clinic.id == id);
    } catch (e) {
      return null;
    }
  }

  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateClinic(
    String clinicId, {
    String? name,
    String? address,
    String? phone,
    String? email,
    String? description,
    String? imageUrl,
  }) {
    final index = _clinics.indexWhere((clinic) => clinic.id == clinicId);
    if (index != -1) {
      final oldClinic = _clinics[index];
      _clinics[index] = Clinic(
        id: oldClinic.id,
        name: name ?? oldClinic.name,
        address: address ?? oldClinic.address,
        phone: phone ?? oldClinic.phone,
        email: email ?? oldClinic.email,
        rating: oldClinic.rating,
        imageUrl: imageUrl ?? oldClinic.imageUrl,
        description: description ?? oldClinic.description,
        services: oldClinic.services,
      );
      notifyListeners();
    }
  }

  List<Service> getClinicServices(String clinicId) {
    final clinic = getClinicById(clinicId);
    if (clinic == null) return [];
    
    return _services
        .where((service) => clinic.services.contains(service.id))
        .toList();
  }
}

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
  });
}

class Service {
  final String id;
  final String name;
  final String description;
  final int duration; // in minutes
  final double price;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
  });
}
