import 'package:flutter/foundation.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class DetailViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  User? user;
  List<Comment> comments = [];
  bool isLoading = false;

  Future<void> loadData(int userId, int postId) async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _api.getUser(userId),
      _api.getComments(postId),
    ]);

    user = results[0] as User;
    comments = results[1] as List<Comment>;
    isLoading = false;
    notifyListeners();
  }
}