import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:async';

import 'package:recommender_flutter/src/models.dart';

class Repository {
  // Databases
  // SecureStorage secureStorage;
  // Future<SharedPreferences> preferences;
  // LeanCloud leancloud;
  // EventBus eventBus;

  Dio httpClient;
  // FlutterLeanCloud
  //     flutterLeanCloud; // Provides IM (and might provide others latter)

  // // Data
  // String sessionToken;

  // Singleton pattern
  static final Repository _repo = Repository._internal();
  static Repository get() => _repo;
  Repository._internal() {
    // this is the initializer
    httpClient = Dio();
    httpClient.options.baseUrl =
        "http://ec2-18-207-92-70.compute-1.amazonaws.com:5432/";
    httpClient.options.receiveTimeout = 60000000;
    httpClient.options.connectTimeout = 60000000; //5s
  }

  Future<bool> trainModel() async {
    Response response = await httpClient.get('train_model');
    final int code = json.decode(response.data)["status"];
    return code == 1;
  }

  Future<double> get mse async {
    Response response = await httpClient.get('test_model');
    final double mse = json.decode(response.data)["MSE"];
    return mse;
  }

  Future<int> randomlyPickUser() async {
    Response response = await httpClient.get('random_user');
    return json.decode(response.data)["user_id"];
  }

  Future<List<Rating>> allExistingRatingsOf(int userId) async {
    Response response = await httpClient.get('$userId/prev_ratings');
    return (json.decode(response.data) as List)
        .map<Rating>((json) => Rating.fromList(json as List))
        .toList();
  }

  Future<List<Recommendation>> recommendFor(int userId) async {
    Response response = await httpClient.get('/$userId/test_recommend');
    return (json.decode(response.data) as List)
        .map<Recommendation>((json) => Recommendation.fromList(json as List))
        .toList();
  }
}
