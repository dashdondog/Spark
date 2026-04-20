import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = 'Admin';
  String _org = 'ClinicBook ХХК';
  String _email = 'admin@clinic.mn';
  String _phone = '+976 9900 0000';

  String get name => _name;
  String get org => _org;
  String get email => _email;
  String get phone => _phone;

  String get initial =>
      _name.trim().isNotEmpty ? _name.trim()[0].toUpperCase() : 'A';

  void update({
    String? name,
    String? org,
    String? email,
    String? phone,
  }) {
    if (name != null) _name = name;
    if (org != null) _org = org;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    notifyListeners();
  }
}
