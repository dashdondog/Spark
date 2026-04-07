import 'package:flutter/material.dart';

class AppLocalizations {
  static const Locale mongolianLocale = Locale('mn', 'MN');
  
  static Map<String, Map<String, String>> _localizedValues = {
    'en_EN': {
      'app_title': 'ClinicBook',
      'app_subtitle': 'Book your clinic appointments with ease',
      'role_customer': 'Customer',
      'role_company': 'Company',
      'role_customer_desc': 'Browse clinics, view services, and book your appointments',
      'role_company_desc': 'Manage your clinic profile, services, and view bookings',
      'browse_clinics': 'Browse Clinics',
      'search_clinics': 'Search clinics...',
      'no_clinics_found': 'No clinics found',
      'no_clinics_available': 'No clinics available',
      'try_adjusting_search': 'Try adjusting your search terms',
      'booking_error': 'Booking Error',
      'clinic_service_not_found': 'Clinic or service not found',
      'book_appointment': 'Book Appointment',
      'select_date_time': 'Select Date and Time',
      'personal_info': 'Personal Information',
      'full_name': 'Full Name',
      'email': 'Email',
      'phone': 'Phone',
      'confirm_booking': 'Confirm Booking',
      'booking_confirmed': 'Booking Confirmed',
      'booking_success_message': 'Your appointment has been successfully booked!',
      'back_to_home': 'Back to Home',
      'clinic_profile': 'Clinic Profile',
      'services': 'Services',
      'duration_minutes': 'minutes',
      'price': 'Price',
      'company_dashboard': 'Company Dashboard',
      'manage_bookings': 'Manage Bookings',
      'manage_services': 'Manage Services',
      'clinic_settings': 'Clinic Settings',
      'general_consultation': 'General Consultation',
      'dental_checkup': 'Dental Check-up',
      'vaccination': 'Vaccination',
      'physical_therapy': 'Physical Therapy',
      'general_consultation_desc': 'General health check-up and consultation',
      'dental_checkup_desc': 'Complete dental examination',
      'vaccination_desc': 'Routine immunization services',
      'physical_therapy_desc': 'Rehabilitation and therapy sessions',
      'required_field': 'This field is required',
      'invalid_email': 'Please enter a valid email',
      'invalid_phone': 'Please enter a valid phone number',
      'select_datetime': 'Please select date and time',
      'clinic': 'Clinic',
      'service': 'Service',
      'duration': 'Duration',
      'select_date_time': 'Select Date & Time',
      'select_date_time_hint': 'Select date and time',
      'your_information': 'Your Information',
      'enter_full_name': 'Enter your full name',
      'enter_email_address': 'Enter your email address',
      'phone_number': 'Phone Number',
      'enter_phone_number': 'Enter your phone number',
      'please_enter_name': 'Please enter your name',
      'please_enter_email': 'Please enter your email',
      'please_enter_phone': 'Please enter your phone number',
      'complete_booking': 'Complete Booking',
      'booking_confirmed_success': 'Booking confirmed successfully!',
      'booking_failed': 'Booking failed',
      'please_select_datetime': 'Please select a date and time',
    },
    'mn_MN': {
      'app_title': 'Клиникин Захиалга',
      'app_subtitle': 'Клиникин цагаа хялбархан захиалаарай',
      'role_customer': 'Үйлчлүүлэгч',
      'role_company': 'Байгууллага',
      'role_customer_desc': 'Клиникуудыг харах, үйлчилгээг үзэх, цагаа захиалах',
      'role_company_desc': 'Клиникин профайл, үйлчилгээг удирдах, захиалгуудыг харах',
      'browse_clinics': 'Клиникуудыг харах',
      'search_clinics': 'Клиник хайх...',
      'no_clinics_found': 'Клиник олдсонгүй',
      'no_clinics_available': 'Боломжтой клиник байхгүй',
      'try_adjusting_search': 'Хайлтын үгээ өөрчлөн үзнэ үү',
      'booking_error': 'Захиалгын алдаа',
      'clinic_service_not_found': 'Клиник эсвэл үйлчилгээ олдсонгүй',
      'book_appointment': 'Цаг захиалах',
      'select_date_time': 'Огноо болон Цаг сонгох',
      'personal_info': 'Хувийн мэдээлэл',
      'full_name': 'Бүтэн нэр',
      'email': 'И-мэйл',
      'phone': 'Утас',
      'confirm_booking': 'Захиалгыг батлах',
      'booking_confirmed': 'Захиалга батлагдсан',
      'booking_success_message': 'Таны цаг амжилттай захиалагдлаа!',
      'back_to_home': 'Нүүр хуудас руу буцах',
      'clinic_profile': 'Клиникин профайл',
      'services': 'Үйлчилгээ',
      'duration_minutes': 'минут',
      'price': 'Үнэ',
      'company_dashboard': 'Байгууллагын хяналтын самбар',
      'manage_bookings': 'Захиалгуудыг удирдах',
      'manage_services': 'Үйлчилгээг удирдах',
      'clinic_settings': 'Клиникин тохиргоо',
      'general_consultation': 'Ерөнхий зөвлөгөө',
      'dental_checkup': 'Шүдний үзлэг',
      'vaccination': 'Тариа',
      'physical_therapy': 'Физикийн эмчилгээ',
      'general_consultation_desc': 'Эрүүл мэндийн ерөнхий үзлэг ба зөвлөгөө',
      'dental_checkup_desc': 'Шүдний бүрэн үзлэг',
      'vaccination_desc': 'Тогтмол дархлаажуулалтын үйлчилгээ',
      'physical_therapy_desc': 'Сэргээн засах ба эмчилгээний суулгууд',
      'required_field': 'Энэ талбарыг бөглөх шаардлагатай',
      'invalid_email': 'Зөв и-мэйл хаяг оруулна уу',
      'invalid_phone': 'Зөв утасны дугаар оруулна уу',
      'select_datetime': 'Огноо болон цаг сонгоно уу',
      'clinic': 'Клиник',
      'service': 'Үйлчилгээ',
      'duration': 'Үргэлжлэх хугацаа',
      'select_date_time': 'Огноо болон Цаг сонгох',
      'select_date_time_hint': 'Огноо болон цаг сонгоно уу',
      'your_information': 'Таны мэдээлэл',
      'enter_full_name': 'Бүтэн нэрээ оруулна уу',
      'enter_email_address': 'И-мэйл хаягаа оруулна уу',
      'phone_number': 'Утасны дугаар',
      'enter_phone_number': 'Утасны дугаараа оруулна уу',
      'please_enter_name': 'Нэрээ оруулна уу',
      'please_enter_email': 'И-мэйлээ оруулна уу',
      'please_enter_phone': 'Утасны дугаараа оруулна уу',
      'complete_booking': 'Захиалгыг дуусгах',
      'booking_confirmed_success': 'Захиалга амжилттай батлагдлаа!',
      'booking_failed': 'Захиалга амжилтгүй боллоо',
      'please_select_datetime': 'Огноо болон цаг сонгоно уу',
    },
  };

  static AppLocalizations? _instance;

  static AppLocalizations of(BuildContext context) {
    _instance ??= AppLocalizations._internal();
    return _instance!;
  }

  AppLocalizations._internal();

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Locale? currentLocale;

  static String getString(String key) {
    final locale = currentLocale ?? const Locale('mn', 'MN');
    final localeKey = '${locale.languageCode}_${locale.countryCode}';
    
    if (_localizedValues.containsKey(localeKey)) {
      return _localizedValues[localeKey]![key] ?? 
             _localizedValues['en_EN']![key] ?? 
             key;
    }
    
    return _localizedValues['en_EN']![key] ?? key;
  }

  // Getters for easy access
  String get appTitle => getString('app_title');
  String get appSubtitle => getString('app_subtitle');
  String get roleCustomer => getString('role_customer');
  String get roleCompany => getString('role_company');
  String get roleCustomerDesc => getString('role_customer_desc');
  String get roleCompanyDesc => getString('role_company_desc');
  String get browseClinics => getString('browse_clinics');
  String get searchClinics => getString('search_clinics');
  String get noClinicsFound => getString('no_clinics_found');
  String get noClinicsAvailable => getString('no_clinics_available');
  String get tryAdjustingSearch => getString('try_adjusting_search');
  String get bookingError => getString('booking_error');
  String get clinicServiceNotFound => getString('clinic_service_not_found');
  String get bookAppointment => getString('book_appointment');
  String get selectDateTime => getString('select_date_time');
  String get personalInfo => getString('personal_info');
  String get fullName => getString('full_name');
  String get email => getString('email');
  String get phone => getString('phone');
  String get confirmBooking => getString('confirm_booking');
  String get bookingConfirmed => getString('booking_confirmed');
  String get bookingSuccessMessage => getString('booking_success_message');
  String get backToHome => getString('back_to_home');
  String get clinicProfile => getString('clinic_profile');
  String get services => getString('services');
  String get durationMinutes => getString('duration_minutes');
  String get price => getString('price');
  String get companyDashboard => getString('company_dashboard');
  String get manageBookings => getString('manage_bookings');
  String get manageServices => getString('manage_services');
  String get clinicSettings => getString('clinic_settings');
  String get generalConsultation => getString('general_consultation');
  String get dentalCheckup => getString('dental_checkup');
  String get vaccination => getString('vaccination');
  String get physicalTherapy => getString('physical_therapy');
  String get generalConsultationDesc => getString('general_consultation_desc');
  String get dentalCheckupDesc => getString('dental_checkup_desc');
  String get vaccinationDesc => getString('vaccination_desc');
  String get physicalTherapyDesc => getString('physical_therapy_desc');
  String get requiredField => getString('required_field');
  String get invalidEmail => getString('invalid_email');
  String get invalidPhone => getString('invalid_phone');
  String get selectDatetime => getString('select_datetime');
  String get clinic => getString('clinic');
  String get service => getString('service');
  String get duration => getString('duration');
  String get selectDateTimeHint => getString('select_date_time_hint');
  String get yourInformation => getString('your_information');
  String get enterFullName => getString('enter_full_name');
  String get enterEmailAddress => getString('enter_email_address');
  String get phoneNumber => getString('phone_number');
  String get enterPhoneNumber => getString('enter_phone_number');
  String get pleaseEnterName => getString('please_enter_name');
  String get pleaseEnterEmail => getString('please_enter_email');
  String get pleaseEnterPhone => getString('please_enter_phone');
  String get completeBooking => getString('complete_booking');
  String get bookingConfirmedSuccess => getString('booking_confirmed_success');
  String get bookingFailed => getString('booking_failed');
  String get pleaseSelectDatetime => getString('please_select_datetime');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['mn', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations.currentLocale = locale;
    return AppLocalizations._internal();
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
