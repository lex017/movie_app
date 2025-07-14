import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:movie_app/detailTailler.dart';

class Movie extends StatefulWidget {
  const Movie({super.key});

  @override
  State<Movie> createState() => _PromotionState();
}

class _PromotionState extends State<Movie> {
  List<Map<String, dynamic>> promotions = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.198:8000/movie'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          promotions = data
              .where((item) => item['status'] == 'promotion')
              .map<Map<String, dynamic>>((item) => {
                    'mv_name': item['mv_name'],
                    'posterURL': getImageUrl(item['posterURL']),
                  })
              .toList();
        });
      } else {
        print('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getImageUrl(String posterURL) {
    if (posterURL.startsWith('http://') || posterURL.startsWith('https://')) {
      return posterURL;
    } else {
      return "http://192.168.0.198/movie_img/$posterURL";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Promotions")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: promotions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: promotions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => trailer(
                              title: promotions[index]["mv_name"]!,
                              imageUrl: promotions[index]["posterURL"]!,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                promotions[index]["posterURL"]!,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                promotions[index]["mv_name"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
