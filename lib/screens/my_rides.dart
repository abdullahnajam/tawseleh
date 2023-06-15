import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tawseleh/screens/edit_ride.dart';
import 'package:tawseleh/widgets/custom_appbar.dart';

import '../model/ride_model.dart';
import '../utils/constants.dart';

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({Key? key}) : super(key: key);

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'My Rides'.tr()),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('rides')
                    .where('userId',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .orderBy("startDateInMilli",descending: true).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print('${snapshot.error}');
                    return Text('Something went wrong ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.size==0) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/json/empty.json',height: 200),
                          SizedBox(height: 20,),
                          Text('No Rides Available'.tr(),style: TextStyle(fontSize: 18),)
                        ],
                      ),
                    );
                  }

                  return  ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      RideModel model=RideModel.fromMap(data,document.reference.id);
                      return myRideCard(model);
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget myRideCard(RideModel model){
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              color: primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        image: DecorationImage(
                            image: NetworkImage(model.image),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Text('${model.departureNeighbour.tr()}, ${model.departureCity.tr()} ${'to'.tr()} ${model.arrivalNeighbour.tr()}, ${model.arrivalCity.tr()}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),),
                              SizedBox(height: 5,),
                              Text('${model.date} ${model.time}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w300,fontSize: 14),),


                            ],
                          ),
                        ),
                        InkWell(
                          onTap: ()async{
                            CoolAlert.show(
                              context: context,
                              title: 'Delete the Ride'.tr(),
                              type: CoolAlertType.confirm,
                              text: 'Are you sure you want to delete this ride?'.tr(),
                              onConfirmBtnTap: (){
                                FirebaseFirestore.instance.collection('rides').doc(model.id).delete();
                              }
                            );                          
                            },

                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.delete,color: Colors.red,),
                          ),
                        ),
                        SizedBox(width: 10,),
                        InkWell(
                          onTap: ()async{
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  EditRideScreen(model)));
                          },

                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit,color: primaryColor,),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          RotatedBox(
            quarterTurns: -1,
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: secondaryColor,
              child: Text('${'JOD'.tr()} ${model.pricePerSeat}${'/Per Seat'.tr()}' ,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w300,fontSize: 13),),
            ),
          ),
        ],
      ),
    );
  }
}
