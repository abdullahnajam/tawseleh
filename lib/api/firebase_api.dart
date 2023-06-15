import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/model/ride_model.dart';
import 'package:tawseleh/model/user_model.dart';
import 'package:tawseleh/provider/filter_provider.dart';


String getNeighbour(String value){
  final list = value.split(':');
  return list.length > 1 ? list.last ?? '': '';

}

String getCity(String value){
  final list = value.split(':');
  return list.first ?? '';

}

bool dateRangesIntersect(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
  return start1.isBefore(end2) && start2.isBefore(end1);
}


class FirebaseApi{


  static Future<UserModel> getUserData(userId)async{
    UserModel? user;
    await FirebaseFirestore.instance.collection('users').doc(userId).get().then((DocumentSnapshot documentSnapshot) async{
      if (documentSnapshot.exists) {
        print('exists');
        Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
        user=UserModel.fromMap(data,documentSnapshot.reference.id);
      }
      else{
        print('N/A');
      }
    });
    return user!;
  }

  static Future<List<RideModel>> getRides(BuildContext context)async{
    print('rides');
    List<RideModel> rides=[];
    final provider = Provider.of<FilterProvider>(context, listen: false);
    await FirebaseFirestore.instance.collection('rides')
        //.where("userId",isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        RideModel rideModel=RideModel.fromMap(data, doc.reference.id);
        bool filtered=true;
        print(doc.reference.id);
        //date filter
        if(dateRangesIntersect(provider.startDate,provider.endDate,DateTime.fromMillisecondsSinceEpoch(rideModel.startDateInMilli),DateTime.fromMillisecondsSinceEpoch(rideModel.endDateInMilli))){
          filtered=true;

        }
        else{
          filtered=false;

        }
        //price filter
        if(filtered && (rideModel.pricePerSeat<provider.priceEnd && rideModel.pricePerSeat>provider.priceStart)){
          filtered=true;
        }
        else{
          filtered=false;
        }
        //gender filter
        if(filtered && provider.gender==null){
          filtered=true;
        }
        else{
          if(provider.gender=='Both'){
            filtered=true;
          }
          else{
            if(filtered && ((rideModel.gender==provider.gender) || provider.gender=='Both')){
              filtered=true;
            }
            else{
              filtered=false;
            }
          }
        }
        //departure filter
        if(filtered && provider.departure==''){
          filtered=true;
        }
        else{
          if(filtered && ('${rideModel.departureCity}:${rideModel.departureNeighbour}'==provider.departure)){
            filtered=true;
          }
          else{
            filtered=false;
          }
        }
        //arrival filter
        if(filtered && provider.arrival==''){
          filtered=true;
        }
        else{
          if(filtered && ('${rideModel.arrivalCity}:${rideModel.arrivalNeighbour}'==provider.arrival)){

            filtered=true;
          }
          else{
            filtered=false;
          }
        }


        if(filtered){
          rides.add(rideModel);
        }
      });
    });
    return rides;
  }
}