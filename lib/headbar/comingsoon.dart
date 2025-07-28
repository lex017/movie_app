import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/detailcoming.dart';

class Comingsoon extends StatefulWidget {
  @override
  State<Comingsoon> createState() => _ComingsoonState();
}

class _ComingsoonState extends State<Comingsoon> {
  List<Map<String, dynamic>> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.196:8000/movie'), // Your API URL
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          movies = data
              .where((item) => item['status'] == 'comming') // Filter status 'comming'
              .map<Map<String, dynamic>>((item) => {
                    'mv_name': item['mv_name'],
                    'posterURL': item['posterURL'],
                    'releaseDate': item['releaseDate'] ?? 'Unknown',
                    'description': item['description'] ?? 'No description available',
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
      return "http://192.168.0.196/movie_img/$posterURL";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coming Soon")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: movies.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final imageUrl = getImageUrl(movie["posterURL"] ?? "");

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Detailcoming(
                              title: movie["mv_name"] ?? "No Title",
                              imageUrl: imageUrl,
                              releaseDate: movie["releaseDate"] ?? "Unknown",
                              description: movie["description"] ?? "No description available",
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.network(
                                imageUrl,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image, size: 60),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                movie["mv_name"] ?? "No Title",
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
