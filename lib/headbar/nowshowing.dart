import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/detailmovie.dart';

class Nowshowing extends StatefulWidget {
  final String uid;
  const Nowshowing({super.key, required this.uid});

  @override
  State<Nowshowing> createState() => _NowshowingState();
}

class _NowshowingState extends State<Nowshowing> {
  List<Map<String, dynamic>> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.126.1:8000/movie'), 
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
           movies = data
              .where((item) => item['status'] == 'now') 
              .map<Map<String, dynamic>>((item) => {
                    'mv_name': item['mv_name'],
                    'mv_id': item['mv_id'],
                    'posterURL': item['posterURL'],
                    'description': item['description'],
                    'theaters': item['theaters'],
                    'release_date': item['release_date'],
                    'price': item['price'],
                    'seat': item['seat'],
                    'posterURL': item['posterURL']
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
      return "http://192.168.0.198/movie_img/$posterURL"; // 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Now Showing")),
      body: movies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  final imageUrl = getImageUrl(movie["posterURL"]);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetails(
                            title: movie["mv_name"],
                            description: movie["description"],
                            imageUrl: imageUrl, 
                            theaters: movie["theaters"],
                            price: movie["price"],
                            seat: movie["seat"], 
                            movieId: movie["mv_id"], 
                            date: movie['release_date'], 
                            uid: widget.uid, image: movie["posterURL"],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                      child: Icon(Icons.broken_image));
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              movie["mv_name"] ?? "",
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
    );
  }
}
