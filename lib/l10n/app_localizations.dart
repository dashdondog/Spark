import 'package:flutter/material.dart';

class AppLocalizations {
  static const Locale mongolianLocale = Locale('mn', 'MN');

  static final Map<String, Map<String, String>> _localizedValues = {
    'en_EN': {
      'app_title': 'MedCare 24x7',
      'app_subtitle': 'Your Health, Our Priority',
      'role_customer': 'Patient',
      'role_company': 'Doctor / Clinic',
      'role_customer_desc': 'Browse clinics, view services, and book appointments',
      'role_company_desc': 'Manage your clinic profile, services, and bookings',
      'browse_clinics': 'Browse Clinics',
      'search_clinics': 'Search doctor, clinic, service...',
      'no_clinics_found': 'No clinics found',
      'no_clinics_available': 'No clinics available',
      'try_adjusting_search': 'Try adjusting your search terms',
      'booking_error': 'Booking Error',
      'clinic_service_not_found': 'Clinic or service not found',
      'book_appointment': 'Book Appointment',
      'select_date_time': 'Select Date & Time',
      'select_date_time_hint': 'Select date and time',
      'personal_info': 'Patient Information',
      'full_name': 'Full Name',
      'email': 'Email Address',
      'phone': 'Phone',
      'confirm_booking': 'Confirm Booking',
      'booking_confirmed': 'Booking Confirmed!',
      'booking_success_message': 'Your appointment has been successfully scheduled.',
      'back_to_home': 'Back to Home',
      'clinic_profile': 'Clinic Profile',
      'services': 'Services',
      'duration_minutes': 'min',
      'price': 'Price',
      'company_dashboard': 'Dashboard',
      'manage_bookings': 'Manage Bookings',
      'manage_services': 'Manage Services',
      'clinic_settings': 'Clinic Settings',
      'required_field': 'This field is required',
      'invalid_email': 'Please enter a valid email',
      'invalid_phone': 'Please enter a valid phone number',
      'select_datetime': 'Please select date and time',
      'clinic': 'Clinic',
      'service': 'Service',
      'duration': 'Duration',
      'your_information': 'Patient Information',
      'enter_full_name': 'Enter your full name',
      'enter_email_address': 'Enter your email address',
      'phone_number': 'Phone Number',
      'enter_phone_number': 'Enter your phone number',
      'please_enter_name': 'Please enter your name',
      'please_enter_email': 'Please enter your email',
      'please_enter_phone': 'Please enter your phone number',
      'complete_booking': 'Confirm Booking',
      'booking_confirmed_success': 'Booking confirmed successfully!',
      'booking_failed': 'Booking failed',
      'please_select_datetime': 'Please select a time slot',
    },
    'mn_MN': {
      'app_title': 'МедКэр 24x7',
      'app_subtitle': 'Таны эрүүл мэнд, манай эрхэм зорилго',
      'role_customer': 'Үйлчлүүлэгч',
      'role_company': 'Эмч / Клиник',
      'role_customer_desc': 'Клиникуудыг харах, үйлчилгээ үзэх, цаг захиалах',
      'role_company_desc': 'Клиникин профайл, үйлчилгээ болон захиалгуудыг удирдах',
      'browse_clinics': 'Клиникүүд',
      'search_clinics': 'Эмч, клиник, үйлчилгээ хайх...',
      'no_clinics_found': 'Клиник олдсонгүй',
      'no_clinics_available': 'Боломжтой клиник байхгүй',
      'try_adjusting_search': 'Хайлтын үгээ өөрчлөн үзнэ үү',
      'booking_error': 'Захиалгын алдаа',
      'clinic_service_not_found': 'Клиник эсвэл үйлчилгээ олдсонгүй',
      'book_appointment': 'Цаг захиалах',
      'select_date_time': 'Огноо болон цаг сонгох',
      'select_date_time_hint': 'Огноо болон цаг сонгоно уу',
      'personal_info': 'Өвчтөний мэдээлэл',
      'full_name': 'Бүтэн нэр',
      'email': 'И-мэйл хаяг',
      'phone': 'Утас',
      'confirm_booking': 'Захиалга баталгаажуулах',
      'booking_confirmed': 'Захиалга баталгаажлаа!',
      'booking_success_message': 'Таны цаг амжилттай захиалагдлаа.',
      'back_to_home': 'Нүүр хуудас руу буцах',
      'clinic_profile': 'Клиникин профайл',
      'services': 'Үйлчилгээ',
      'duration_minutes': 'мин',
      'price': 'Үнэ',
      'company_dashboard': 'Хяналтын самбар',
      'manage_bookings': 'Захиалгуудыг удирдах',
      'manage_services': 'Үйлчилгээг удирдах',
      'clinic_settings': 'Клиникин тохиргоо',
      'required_field': 'Энэ талбарыг бөглөх шаардлагатай',
      'invalid_email': 'Зөв и-мэйл хаяг оруулна уу',
      'invalid_phone': 'Зөв утасны дугаар оруулна уу',
      'select_datetime': 'Огноо болон цаг сонгоно уу',
      'clinic': 'Клиник',
      'service': 'Үйлчилгээ',
      'duration': 'Үргэлжлэх хугацаа',
      'your_information': 'Өвчтөний мэдээлэл',
      'enter_full_name': 'Бүтэн нэрээ оруулна уу',
      'enter_email_address': 'И-мэйл хаягаа оруулна уу',
      'phone_number': 'Утасны дугаар',
      'enter_phone_number': 'Утасны дугаараа оруулна уу',
      'please_enter_name': 'Нэрээ оруулна уу',
      'please_enter_email': 'И-мэйлээ оруулна уу',
      'please_enter_phone': 'Утасны дугаараа оруулна уу',
      'complete_booking': 'Захиалга баталгаажуулах',
      'booking_confirmed_success': 'Захиалга амжилттай баталгаажлаа!',
      'booking_failed': 'Захиалга амжилтгүй боллоо',
      'please_select_datetime': 'Цаг сонгоно уу',
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
          _localizedValues['mn_MN']![key] ??
          key;
    }
    return _localizedValues['mn_MN']![key] ?? key;
  }

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
  String get selectDateTimeHint => getString('select_date_time_hint');
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
  String get requiredField => getString('required_field');
  String get invalidEmail => getString('invalid_email');
  String get invalidPhone => getString('invalid_phone');
  String get selectDatetime => getString('select_datetime');
  String get clinic => getString('clinic');
  String get service => getString('service');
  String get duration => getString('duration');
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

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['mn', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations.currentLocale = locale;
    return AppLocalizations._internal();
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
