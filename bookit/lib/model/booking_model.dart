import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String? docId = '', services = '';
  String serviceId = '',
      serviceName = '',
      categoryBook = '',
      customerId = '',
      customerName = '',
      customerPhone = '',
      facilityAddress = '',
      facilityId = '',
      facilityName = '',
      time = '';
  double totalPrice = 0;
  bool done = false;
  int slot = 0, timeStamp = 0;

  DocumentReference? reference;

  BookingModel({this.docId, required this.serviceId, required this.serviceName,
    required this.categoryBook, required this.customerId,
    required this.totalPrice, required this.customerName,
    required this.customerPhone, required this.facilityAddress,
    required this.facilityId, required this.facilityName,
    this.services, required this.time, required this.done,
    required this.slot, required this.timeStamp});

  BookingModel.fromJson(Map<String, dynamic> json) {
    docId = json['docId'];
    serviceId = json['serviceId'];
    serviceName = json['serviceName'];
    categoryBook = json['categoryBook'];
    customerId = json['customerId'];
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    facilityAddress = json['facilityAddress'];
    facilityId = json['facilityId'];
    facilityName = json['facilityName'];
    services = json['services'];
    time = json['time'];
    done = json['done'];
    slot = int.parse(json['slot'] == null ? '-1' : json['slot'].toString());
    totalPrice = double.parse(json['totalPrice'] == null ? '0' : json['totalPrice'].toString());
    timeStamp = int.parse(json['timeStamp'] == null ? '0' : json['timeStamp'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['docId'] = this.docId;
    data['serviceId'] = this.serviceId;
    data['serviceName'] = this.serviceName;
    data['categoryBook'] = this.categoryBook;
    data['customerId'] = this.customerId;
    data['customerName'] = this.customerName;
    data['customerPhone'] = this.customerPhone;
    data['facilityAddress'] = this.facilityAddress;
    data['facilityId'] = this.facilityId;
    data['facilityName'] = this.facilityName;
    data['time'] = this.time;
    data['done'] = this.done;
    data['slot'] = this.slot;
    data['timeStamp'] = this.timeStamp;
    return data;
  }


}