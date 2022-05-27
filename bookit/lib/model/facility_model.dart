import 'package:cloud_firestore/cloud_firestore.dart';

class FacilityModel {
  String name = '', address = '';
  String? docId = '';
  DocumentReference? reference;

  FacilityModel({required this.name, required this.address});

  FacilityModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.address;
    data['name'] = this.name;
    return data;
  }
}