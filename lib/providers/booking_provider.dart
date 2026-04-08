import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];
  final List<Clinic> _clinics = [];
  final List<Service> _services = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Clinic> get clinics => List.unmodifiable(_clinics);
  List<Service> get services => List.unmodifiable(_services);

  BookingProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // ── Services ──────────────────────────────────────────────────────────
    _services.addAll([
      Service(
        id: '1',
        name: 'General Consultation',
        description: 'General health check-up and consultation',
        duration: 30,
        price: 50.0,
      ),
      Service(
        id: '2',
        name: 'Dental Check-up',
        description: 'Full dental examination and cleaning',
        duration: 45,
        price: 80.0,
      ),
      Service(
        id: '3',
        name: 'Vaccination',
        description: 'Routine immunization services',
        duration: 15,
        price: 25.0,
      ),
      Service(
        id: '4',
        name: 'Physical Therapy',
        description: 'Rehabilitation and therapeutic sessions',
        duration: 60,
        price: 120.0,
      ),
      Service(
        id: '5',
        name: 'Cardiology Exam',
        description: 'Heart health assessment and ECG',
        duration: 45,
        price: 150.0,
      ),
      Service(
        id: '6',
        name: 'Pediatric Check-up',
        description: 'Child health monitoring and growth assessment',
        duration: 30,
        price: 60.0,
      ),
      Service(
        id: '7',
        name: 'Orthopedic Consult',
        description: 'Bone, joint and muscle evaluation',
        duration: 40,
        price: 100.0,
      ),
      Service(
        id: '8',
        name: 'Eye Examination',
        description: 'Complete vision test and eye health check',
        duration: 30,
        price: 70.0,
      ),
      Service(
        id: '9',
        name: 'Skin Consultation',
        description: 'Dermatology assessment and treatment plan',
        duration: 30,
        price: 90.0,
      ),
      Service(
        id: '10',
        name: 'Blood Test Panel',
        description: 'Comprehensive blood work and lab analysis',
        duration: 20,
        price: 45.0,
      ),
    ]);

    // ── Clinics ───────────────────────────────────────────────────────────
    _clinics.addAll([
      Clinic(
        id: '1',
        name: 'City Medical Center',
        address: '123 Main Street, Downtown',
        phone: '+1 (555) 123-4567',
        email: 'info@citymedical.com',
        rating: 4.5,
        imageUrl: '',
        description:
            'A comprehensive medical center providing high-quality healthcare services with state-of-the-art facilities and a team of experienced specialists dedicated to your well-being.',
        services: ['1', '2', '3'],
      ),
      Clinic(
        id: '2',
        name: 'Family Health Clinic',
        address: '456 Oak Avenue, Westside',
        phone: '+1 (555) 987-6543',
        email: 'contact@familyhealth.com',
        rating: 4.8,
        imageUrl: '',
        description:
            'Your trusted family healthcare provider offering compassionate and personalized medical care for every member of your family, from newborns to seniors.',
        services: ['1', '4', '6'],
      ),
      Clinic(
        id: '3',
        name: 'Bright Smile Dental',
        address: '789 Elm Road, Northpark',
        phone: '+1 (555) 234-5678',
        email: 'hello@brightsmile.com',
        rating: 4.7,
        imageUrl: '',
        description:
            'A modern dental clinic specializing in cosmetic and preventive dentistry. We use the latest technology to ensure comfortable and effective treatments.',
        services: ['2', '10'],
      ),
      Clinic(
        id: '4',
        name: 'Heart & Vascular Institute',
        address: '321 Maple Drive, Eastview',
        phone: '+1 (555) 345-6789',
        email: 'care@heartinstitute.com',
        rating: 4.9,
        imageUrl: '',
        description:
            'A leading cardiology center with expert cardiologists and advanced diagnostic equipment. We provide complete heart care from prevention to treatment.',
        services: ['5', '1', '10'],
      ),
      Clinic(
        id: '5',
        name: "Children's Health Center",
        address: '654 Pine Street, Lakeside',
        phone: '+1 (555) 456-7890',
        email: 'kids@childrenshealth.com',
        rating: 4.6,
        imageUrl: '',
        description:
            'A dedicated pediatric clinic offering specialized care for children from birth through adolescence in a warm and friendly environment.',
        services: ['6', '3', '1'],
      ),
      Clinic(
        id: '6',
        name: 'Ortho & Sports Medicine',
        address: '987 Cedar Lane, Midtown',
        phone: '+1 (555) 567-8901',
        email: 'info@orthosports.com',
        rating: 4.4,
        imageUrl: '',
        description:
            'Expert care for musculoskeletal injuries and sports-related conditions. Our team of orthopedic surgeons and physical therapists help you recover faster.',
        services: ['7', '4'],
      ),
      Clinic(
        id: '7',
        name: 'Vision Care Eye Clinic',
        address: '147 Birch Blvd, Southgate',
        phone: '+1 (555) 678-9012',
        email: 'see@visioncare.com',
        rating: 4.5,
        imageUrl: '',
        description:
            'Comprehensive eye care services including routine exams, contact lens fittings, and treatment for a full range of eye conditions.',
        services: ['8', '10'],
      ),
      Clinic(
        id: '8',
        name: 'Skin & Wellness Clinic',
        address: '258 Willow Way, Hillcrest',
        phone: '+1 (555) 789-0123',
        email: 'glow@skinwellness.com',
        rating: 4.3,
        imageUrl: '',
        description:
            'A specialized dermatology and wellness clinic offering evidence-based treatments for all skin types and conditions with a focus on long-term skin health.',
        services: ['9', '1'],
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
    _bookings.removeWhere((b) => b.id == bookingId);
    notifyListeners();
  }

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
    return _services
        .where((s) => clinic.services.contains(s.id))
        .toList();
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
    final index = _clinics.indexWhere((c) => c.id == clinicId);
    if (index != -1) {
      final old = _clinics[index];
      _clinics[index] = Clinic(
        id: old.id,
        name: name ?? old.name,
        address: address ?? old.address,
        phone: phone ?? old.phone,
        email: email ?? old.email,
        rating: old.rating,
        imageUrl: imageUrl ?? old.imageUrl,
        description: description ?? old.description,
        services: old.services,
      );
      notifyListeners();
    }
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
  final int duration;
  final double price;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
  });
}
