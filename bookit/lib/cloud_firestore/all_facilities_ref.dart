import 'dart:convert';

import 'package:bookit/model/facility_model.dart';
import 'package:bookit/model/service_model.dart';
import 'package:bookit/state/state_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../model/booking_model.dart';
import '../model/category_model.dart';

// Категории из БД
Future<List<CategoryModel>> getCategories() async {
  var categories = new List<CategoryModel>.empty(growable: true);
  var categoryRef = FirebaseFirestore.instance.collection('AllFacilities');
  var snapshot = await categoryRef.get();
  snapshot.docs.forEach((element) {
    categories.add(CategoryModel.fromJson(element.data()));
  });
  return categories;
}

// Заведения из БД
Future<List<FacilityModel>> getFacilitiesByCategory(String categoryName) async {
  var facilities = new List<FacilityModel>.empty(growable: true);
  var facilityRef = FirebaseFirestore.instance.collection('AllFacilities').doc(categoryName).collection('Branch');
  var snapshot = await facilityRef.get();
  snapshot.docs.forEach((element) {
    var facility = FacilityModel.fromJson(element.data());
    facility.docId = element.id;
    facility.reference = element.reference;
    facilities.add(facility);
  });
  return facilities;
}

// Услуги из БД
Future<List<ServiceModel>> getServicesByFacilities(FacilityModel facility) async {
  var services = new List<ServiceModel>.empty(growable: true);
  var serviceRef = facility.reference!.collection('Service');
  var snapshot = await serviceRef.get();
  snapshot.docs.forEach((element) {
    var service = ServiceModel.fromJson(element.data());
    service.docId = element.id;
    service.reference = element.reference;
    services.add(service);
  });
  return services;
}

// Расписание из БД
Future<List<int>> getTimeSlotOfService(ServiceModel serviceModel, String date) async {
  List<int> result = new List<int>.empty(growable: true);
  var bookingRef = serviceModel.reference!.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}

Future<bool> checkThisFacility(BuildContext context) async {
  //AllFacilities/Бильярд/Branch/5GmHdXmUDZro22lh7B5q/Service/G6Iu9VryvNmTRyglcv3v
  DocumentSnapshot facilitySnapshot = await FirebaseFirestore.instance
      .collection('AllFacilities')
      .doc('${context.read(selectedCategory).state.name}')
      .collection('Branch')
      .doc('${context.read(selectedFacility).state.docId}')
      .collection('Service')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  return facilitySnapshot.exists;
}

Future<List<int>> getBookingSlot(BuildContext context, String date) async {
  var facilityDocument = FirebaseFirestore.instance
      .collection('AllFacilities')
      .doc('${context.read(selectedCategory).state.name}')
      .collection('Branch')
      .doc('${context.read(selectedFacility).state.docId}')
      .collection('Service')
      .doc(FirebaseAuth.instance.currentUser!.uid);
  List<int> result = new List<int>.empty(growable: true);
  var bookingRef = facilityDocument.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}

Future<BookingModel> getDetailOfBooking(BuildContext context, int timeSlot) async {
  CollectionReference userRef = FirebaseFirestore.instance
      .collection('AllFacilities')
      .doc(context.read(selectedCategory).state.name)
      .collection('Branch')
      .doc(context.read(selectedFacility).state.docId)
      .collection('Service')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection(DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state));
  DocumentSnapshot snapshot = await userRef.doc(timeSlot.toString()).get();
  if (snapshot.exists) {
    var bookingModel = BookingModel.fromJson(json.decode(json.encode(snapshot.data())));
    bookingModel.docId = snapshot.id;
    bookingModel.reference = snapshot.reference;
    context.read(selectedBooking).state = bookingModel;
    return bookingModel;
  } else {
    return BookingModel(customerName: '', categoryBook: '', totalPrice: 0,
        customerPhone: '', time: '', facilityAddress: '', serviceId: '', customerId: '', facilityName: '',
        serviceName: '', facilityId: '', slot: 0, timeStamp: 0, done: false);
  }
}