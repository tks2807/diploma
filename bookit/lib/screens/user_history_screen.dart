import 'dart:developer';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:bookit/cloud_firestore/all_facilities_ref.dart';
import 'package:bookit/cloud_firestore/user_ref.dart';
import 'package:bookit/model/category_model.dart';
import 'package:bookit/model/facility_model.dart';
import 'package:bookit/model/service_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../model/booking_model.dart';
import '../state/state_management.dart';
import '../utils/utils.dart';

class UserHistory extends ConsumerWidget {

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  void cancelBooking(BuildContext context, BookingModel bookingModel) {
    //AllFacilities/Бильярд/Branch/5GmHdXmUDZro22lh7B5q/Service/G6Iu9VryvNmTRyglcv3v/16_05_2022/13
    var batch = FirebaseFirestore.instance.batch();
    var facilityBooking = FirebaseFirestore.instance
    .collection('AllFacilities')
    .doc(bookingModel.categoryBook)
    .collection('Branch')
    .doc(bookingModel.facilityId)
    .collection('Service')
    .doc(bookingModel.serviceId)
    .collection(DateFormat('dd_MM_yyyy').format(DateTime.fromMillisecondsSinceEpoch(bookingModel.timeStamp)))
    .doc(bookingModel.slot.toString());

    var userBooking = bookingModel.reference;

    batch.delete(userBooking!);
    batch.delete(facilityBooking); // не работает

    batch.commit().then((value) {
      context.read(deleteFlagRefresh).state = !context.read(deleteFlagRefresh).state;
    });
  }

  displayUserHistory() {
    return FutureBuilder(
      future: getUserHistory(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var userBookings = snapshot.data as List<BookingModel>;
          if (userBookings == null || userBookings.length == 0) {
            return Center(
              child: Text('Не могу загрузить историю('),
            );
          } else {
            return FutureBuilder(
              future: syncTime(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  var syncTime = snapshot.data as DateTime;
                  return ListView.builder(
                    itemCount: userBookings.length,
                    itemBuilder: (context, index) {
                      var isExpired = DateTime.fromMillisecondsSinceEpoch(userBookings[index].timeStamp).isBefore(syncTime);
                      return Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(22))
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Date', style: GoogleFonts.robotoMono(),),
                                          Text(DateFormat("dd/MM/yyyy").format(
                                              DateTime.fromMillisecondsSinceEpoch(userBookings[index].timeStamp)
                                          ),
                                            style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text('Time', style: GoogleFonts.robotoMono(),),
                                          Text(TIME_SLOT.elementAt(userBookings[index].slot),
                                            style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.bold),)
                                        ],
                                      )
                                    ],
                                  ),
                                  Divider(thickness: 1,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${userBookings[index].facilityName}',
                                            style: GoogleFonts.robotoMono(fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${userBookings[index].serviceName}',
                                            style: GoogleFonts.robotoMono(),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${userBookings[index].facilityAddress}',
                                        style: GoogleFonts.robotoMono(),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: (userBookings[index].done || isExpired) ? null : () {
                                Alert(
                                    context: context,
                                    type: AlertType.warning,
                                    title: 'ОТМЕНИТЬ БРОНЬ',
                                    desc: 'Вы уверены что хотите отменить бронь?',
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          'Отменить',
                                          style: GoogleFonts.robotoMono(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          cancelBooking(context, userBookings[index]);
                                        },
                                        color: Colors.white,
                                      ),
                                      DialogButton(
                                        child: Text(
                                          'Назад',
                                          style: GoogleFonts.robotoMono(color: Colors.black),
                                        ),
                                        onPressed: () => Navigator.of(context).pop(),
                                        color: Colors.white,
                                      ),
                                    ]
                                ).show();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(22),
                                      bottomLeft: Radius.circular(22),
                                    )
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        userBookings[index].done
                                          ? ''
                                          : isExpired
                                            ? 'ИСТЕКЛО'
                                            : 'ОТМЕНИТЬ',
                                        style: GoogleFonts.robotoMono(color: isExpired ? Colors.grey : Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
              });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, watch) {
    var watchRefresh = watch(deleteFlagRefresh).state;
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('История'),
          backgroundColor: Color(0xFF383838),
        ),
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFFDF9EE),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: displayUserHistory(),
        )
      ),
    );
  }
}