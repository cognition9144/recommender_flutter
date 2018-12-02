import 'package:flutter/material.dart';

class Rating {
  final int user;
  final int business;
  final double rate;

  const Rating(this.user, this.business, this.rate);

  Rating.fromList(List<dynamic> list)
      : user = list[0],
        business = list[1],
        rate = list[2];

  // Map<String, dynamic> toJson() => {
  //       'user_id': user,
  //       'restaurant_id': business,
  //       'stars': rate,
  //     };
}

class Recommendation {
  final int business;
  final double real_rate;
  final double predicted_rate;

  const Recommendation(this.business, this.real_rate, this.predicted_rate);

  Recommendation.fromList(List<dynamic> list)
      : business = list[0],
        real_rate = list[1],
        predicted_rate = list[2];

  // Map<String, dynamic> toJson() => {
  //       'user_id': user,
  //       'restaurant_id': business,
  //       'stars': rate,
  //     };
}

class RatingDataSource extends DataTableSource {
  RatingDataSource(this.ratings);

  List<Rating> ratings;
  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= ratings.length) return null;
    final Rating rating = ratings[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${rating.business}')),
      DataCell(Text('${rating.rate}')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => ratings.length;

  @override
  int get selectedRowCount => _selectedCount;

  void sort<T>(Comparable<T> getField(Rating d), bool ascending) {
    ratings.sort((Rating a, Rating b) {
      if (!ascending) {
        final Rating c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }
}
