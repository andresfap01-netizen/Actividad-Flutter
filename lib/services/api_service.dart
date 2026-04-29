// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';

class ApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com";

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse("$baseUrl/posts"));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar posts");
    }
  }

  Future<Post> getPost(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/posts/$id"));
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al cargar post");
    }
  }

  Future<List<Comment>> getComments(int postId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/comments?postId=$postId"));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar comentarios");
    }
  }

  Future<User> getUser(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/users/$userId"));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al cargar usuario");
    }
  }
}
