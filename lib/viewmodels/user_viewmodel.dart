import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserViewModel extends ChangeNotifier {
  final User user;
  UserViewModel(this.user);
}