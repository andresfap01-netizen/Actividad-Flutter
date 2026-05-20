import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Post> posts = [];
  bool isLoading = false;
  String? error;

  Future<void> loadPosts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      posts = await _api.getPosts();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}