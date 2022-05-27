import 'package:bookit/model/booking_model.dart';
import 'package:bookit/model/category_model.dart';
import 'package:bookit/model/services_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/facility_model.dart';
import '../model/service_model.dart';
import '../model/user_model.dart';

// Вход
final userLogged = StateProvider((ref) => FirebaseAuth.instance.currentUser);
final userToken =  StateProvider((ref) => '');
final forceReload = StateProvider((ref) => false);

// Пользователь
final userInformation = StateProvider((ref) => UserModel(name: '', email: ''));

// Бронирование
final currentStep = StateProvider((ref) => 1);
final selectedCategory = StateProvider((ref) => CategoryModel(name: ''));
final selectedFacility = StateProvider((ref) => FacilityModel(name: '', address: ''));
final selectedService = StateProvider((ref) => ServiceModel());
final selectedDate = StateProvider((ref) => DateTime.now());
final selectedTimeSlot = StateProvider((ref) => -1);
final selectedTime = StateProvider((ref) => '');

// Удаление
final deleteFlagRefresh = StateProvider((ref) => false);

// Админ
final staffStep = StateProvider((ref) => 1);
final selectedBooking = StateProvider((ref) => BookingModel(customerName: '', categoryBook: '', totalPrice: 0,
    customerPhone: '', time: '', facilityAddress: '', serviceId: '', customerId: '', facilityName: '', 
    serviceName: '', facilityId: '', slot: 0, timeStamp: 0, done: false));
final selectedServices = StateProvider((ref) => List<ServicesModel>.empty(growable: true));