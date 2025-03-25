import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey =
      '87f405ce6d0c47f8818a2fde683f737e'; // Replace with your actual API key

  Future<List<Article>> fetchTechNews() async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/top-headlines?country=us&category=technology&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> articles = jsonData['articles'];
      return articles.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
