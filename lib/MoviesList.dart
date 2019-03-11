import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import './Service/MovieApi.dart';

class MovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies',
      theme: ThemeData(primarySwatch: Colors.red),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Movies'),
        ),
        body: MovieListPage(),
      ),
    );
  }
}

class MovieListPage extends StatefulWidget {
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final padding = 30.0;
  final offset = 30.0 - 10.0;

  List<Movie> movies = [];
  int page = 0;

  final _perPage = 20;
  int _total;
  final border = BoxDecoration(
      // border: Border.all(width: 1, color: Colors.black26),
      borderRadius: BorderRadius.all(Radius.circular(6)),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(4.0, 4.0),
            spreadRadius: 7.0),
      ]);

  @override
  void initState() {
    super.initState();
    _requestData();
  }

  Future<Null> _requestData() async {
    await MovieApi().getMovieList(count: _perPage).then((moviesData) {
      _total = moviesData.total;
      setState(() {
        movies = moviesData.movies;
      });
    });
    return;
  }

  _requestMoreData(int page) {
    print('page = $page');
    MovieApi().getMovieList(page: page, count: _perPage).then((moviesData) {
      _total = moviesData.total;
      setState(() {
        movies += moviesData.movies;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // return LoadingListPage();

    if (movies.length == 0) {
      // return Center(
      //   child: CircularProgressIndicator(),
      // );
      return LoadingListPage();
    } else {
      return RefreshIndicator(
        child: ListView.builder(
          itemCount: movies.length * 2 + 1,
          itemBuilder: _buildRow,
        ),
        onRefresh: _requestData,
      );
    }
  }

  Container _buildRow(BuildContext context, int index) {
    if (index == movies.length * 2) {
      return Container(
        alignment: Alignment.center,
        height: 60,
        child: (movies.length >= _total)
            ? Text(
                "No More",
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              )
            : FlatButton(
                child: Text(
                  "Load More",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () {
                  _requestMoreData(++page);
                }),
      );
    }

    if (index.isEven) {
      return Container(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
      );
    }

    Movie movie = movies[index ~/ 2];

    return Container(
        margin: EdgeInsets.only(
          left: padding,
          right: padding,
        ),
        width: MediaQuery.of(context).size.width,
        height: 250,
        child: GestureDetector(
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) {
            //   return Scaffold(
            //     appBar: AppBar(
            //       title: const Text('Detail'),
            //     ),
            //     body: Center(
            //       child: Image.network(movie.poster),
            //     ),
            //   );
            // }));
            launch("https://m.douban.com/movie/subject/" + movie.id);
          },
          child: Stack(
            children: <Widget>[
              Positioned(
                  left: MediaQuery.of(context).size.width / 2.0 -
                      padding -
                      offset,
                  right: 0,
                  child: Container(
                    decoration: border,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      child: Image.network(
                        movie.poster,
                        width:
                            MediaQuery.of(context).size.width / 2.0 - padding,
                        height: 250,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )),
              Positioned(
                top: 20,
                bottom: 20,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: border,
                  width: MediaQuery.of(context).size.width / 2.0 - padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        movie.title,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'By ' + movie.director,
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.normal,
                              color: Color.fromRGBO(191, 191, 191, 1.0)),
                        ),
                      ),
                      _buildRatingWidget(movie),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildRatingWidget(Movie movie) {
    List<Widget> widgets = [];
    int floor = movie.stars ~/ 10;
    final size = 14.0;
    final color = Color.fromRGBO(221, 166, 81, 1.0);
    for (var i = 1; i <= 5; i++) {
      if (i <= floor) {
        widgets.add(Icon(
          Icons.star,
          color: color,
          size: size,
        ));
      } else if (i == floor + 1 && movie.stars % 10 != 0) {
        widgets.add(Icon(
          Icons.star_half,
          color: color,
          size: size,
        ));
      } else {
        widgets.add(Icon(
          Icons.star,
          color: Color.fromRGBO(238, 214, 173, 0.6),
          size: size,
        ));
      }
    }
    widgets.add(Text(movie.rating,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.bold)));
    return Padding(
      padding: EdgeInsets.only(top: 6),
      child: Row(
        children: widgets,
      ),
    );
  }
}

class LoadingListPage extends StatelessWidget {
  final padding = 30.0;
  final offset = 30.0 - 10.0;

  final border = BoxDecoration(
      // border: Border.all(width: 1, color: Colors.black26),
      borderRadius: BorderRadius.all(Radius.circular(6)),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(4.0, 4.0),
            spreadRadius: 7.0),
      ]);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(30),
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext cont, int index) {
        return Container(
          padding: EdgeInsets.only(bottom: 24),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              width: double.infinity,
              height: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 12.0,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                              padding: EdgeInsets.only(right: 30),
                              child: Container(
                                height: 10.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                              padding: EdgeInsets.only(right: 24),
                              child: Container(
                                height: 10.0,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: border,
                    width: MediaQuery.of(cont).size.width / 2.0,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
