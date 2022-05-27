import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String name = '';
  String? docId = '';
  double rating = 0;
  int ratingTimes = 0;
  int price = 0;

  DocumentReference? reference;

  ServiceModel();

  ServiceModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    rating = double.parse(json['rating'] == null ? '0' : json['rating'].toString());
    ratingTimes = int.parse(json['ratingTimes'] == null ? '0' : json['ratingTimes'].toString());
    price = int.parse(json['price'] == null ? '0' : json['price'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['rating'] = this.rating;
    data['ratingTimes'] = this.ratingTimes;
    data['price'] = this.price;
    return data;
  }

}