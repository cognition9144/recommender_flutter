import 'package:flutter/material.dart';
import 'package:recommender_flutter/src/models.dart';
import 'package:recommender_flutter/src/repository.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(title: 'Restaurant Recommender System Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _trainTime = 84;
  double _mse;
  int _randomPickedUser;
  List<Rating> _userExistingRatings;
  List<Recommendation> _recommendedRestaurant;
  bool isLoading = false;
  RatingDataSource _ratingDataSource;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _randomlyPickUser();
  }

  Future<void> _randomlyPickUser() async {
    final int userID = await Repository.get().randomlyPickUser();
    setState(() {
      _randomPickedUser = userID;
    });
    final List<Rating> existingRatings =
        await Repository.get().allExistingRatingsOf(_randomPickedUser);
    setState(() {
      _userExistingRatings = existingRatings;
      _ratingDataSource = RatingDataSource(_userExistingRatings);
    });
  }

  void _sort<T>(
      Comparable<T> getField(Rating d), int columnIndex, bool ascending) {
    _ratingDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final Widget _body = ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // Train
        RaisedButton.icon(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            var startTime = new DateTime.now();
            final bool success = await Repository.get().trainModel();
            var endTime = new DateTime.now();
            final int timeUsed = endTime.difference(startTime).inSeconds;
            // final double timeUsed = 10;
            if (success && timeUsed != null) {
              setState(() {
                _trainTime = timeUsed;
                isLoading = false;
              });
            }
          },
          icon: Icon(_trainTime == null ? Icons.directions_run : Icons.check),
          label: Text(_trainTime == null
              ? " Train"
              : "Train Success in ${_trainTime}s!"),
          color: _trainTime == null ? Colors.lime : Colors.green,
        ),
        // Calculate MSE
        _trainTime == null
            ? Container()
            : RaisedButton.icon(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final double mse = await Repository.get().mse;
                  // final double mse = 10;
                  if (mse != null) {
                    setState(() {
                      _mse = mse;
                      isLoading = false;
                    });
                  }
                },
                icon: Icon(_mse == null ? Icons.error_outline : Icons.check),
                label: Text(_mse == null ? "Calculate MSE" : "MSE is $_mse"),
                color: _mse == null ? Colors.lime : Colors.green,
              ),
        // Randomly pick a user & pull his/her existing rating data
        _trainTime == null
            ? Container()
            : RaisedButton.icon(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await _randomlyPickUser();

                  setState(() {
                    isLoading = false;
                  });
                },
                icon:
                    Icon(_randomPickedUser == null ? Icons.face : Icons.check),
                label: _randomPickedUser == null
                    ? const Text("Randomly pick a user")
                    : Text("User $_randomPickedUser picked"),
                color: _randomPickedUser == null ? Colors.lime : Colors.green,
              ),

        // User's existing rating data
        _ratingDataSource == null
            ? Container()
            : PaginatedDataTable(
                header: Text('Existing ratings of user $_randomPickedUser'),
                rowsPerPage: _rowsPerPage,
                onRowsPerPageChanged: (int value) {
                  setState(() {
                    _rowsPerPage = value;
                  });
                },
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: <DataColumn>[
                  DataColumn(
                      label: const Text('Business ID'),
                      onSort: (int columnIndex, bool ascending) => _sort<num>(
                          (Rating d) => d.business, columnIndex, ascending)),
                  DataColumn(
                      label: const Text('Rating'),
                      numeric: true,
                      onSort: (int columnIndex, bool ascending) => _sort<num>(
                          (Rating d) => d.rate, columnIndex, ascending)),
                ],
                source: RatingDataSource(_userExistingRatings)),

        // Predict and recommend the top rating restaurant of that user
        _userExistingRatings == null
            ? Container()
            : RaisedButton.icon(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final recommendedRestaurant =
                      await Repository.get().recommendFor(_randomPickedUser);
                  setState(() {
                    _recommendedRestaurant = recommendedRestaurant;
                    isLoading = true;
                  });
                },
                icon: Icon(_recommendedRestaurant == null
                    ? Icons.restaurant
                    : Icons.check),
                label: _recommendedRestaurant == null
                    ? Text("Recommend for user $_randomPickedUser")
                    : Text("Recommendation is list below"),
                color:
                    _recommendedRestaurant == null ? Colors.lime : Colors.green,
              ),
        _recommendedRestaurant == null || _recommendedRestaurant.isEmpty
            ? Container()
            : Card(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text("${_recommendedRestaurant[0].business} ",
                          style: Theme.of(context).textTheme.display2),
                      Text(
                        "of real rating ${_recommendedRestaurant[0].real_rate.clamp(1.0, 5.0)}",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.black45),
                      ),
                      Text(
                        "with predicted rating ${_recommendedRestaurant[0].predicted_rate.clamp(1.0, 5.0)}",
                        style: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          _body,
          isLoading ? LinearProgressIndicator() : Container()
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   // onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
