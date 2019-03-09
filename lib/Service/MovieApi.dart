import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

const bool inProduction = const bool.fromEnvironment("dart.vm.product");

class MovieApi {
  Future<Movies> getMovieList({int page = 0, int count = 20}) async {
    var client =HttpClient();
    int start = page * count;
    var request = await client.getUrl(Uri.parse('https://api.douban.com/v2/movie/top250?start=$start&count=$count'));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    Map data = json.decode(responseBody);
    if (!inProduction) {
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String prettyprint = encoder.convert(data);
      debugPrint(prettyprint);
    }
    return Movies.fromJSON(data);
  }
}


class Movies {
  int count;
  int start;
  int total;
  List<Movie> movies;

  Movies({this.count, this.start, this.total, this.movies});

   Movies.fromJSON(Map data) {
    this.count = data['count'];
    this.start = data['start'];
    this.total = data['total'];

    List<Movie> movies = [];
    (data['subjects'] as List).forEach((item) {
      Movie movie = Movie.fromJSON(item);
      movies.add(movie);
    });

    this.movies = movies;
  }
}

class Movie {
  String id;
  String rating;
  int stars;
  String title;
  String director;
  String year;
  String poster;

  Movie({
    this.id,
    this.rating,
    this.title,
    this.director,
    this.year,
    this.stars,
    this.poster,
  });

  Movie.fromJSON(Map<String, dynamic> json) {
    this.id = json['id'];
    this.rating = json['rating']['average'].toString();
    this.stars = int.parse(json['rating']['stars']);
    this.title = json['original_title'];
    this.director = json['directors'][0]['name'];
    this.year = json['year'];
    this.poster = json['images']['medium'];
  }
}