import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/api/firebase_api.dart';
import 'package:tawseleh/model/ride_model.dart';
import 'package:tawseleh/model/user_model.dart';
import 'package:tawseleh/provider/filter_provider.dart';
import 'package:tawseleh/screens/filter_screen.dart';
import 'package:tawseleh/utils/constants.dart';
import 'package:tawseleh/widgets/profile_image.dart';

import '../api/db_api.dart';
import '../model/city_model.dart';
import '../widgets/custom_appbar.dart';
import 'chat/chat_screen.dart';

class RideListScreen extends StatefulWidget {
  const RideListScreen({Key? key}) : super(key: key);

  @override
  State<RideListScreen> createState() => _RideListScreenState();
}

class _RideListScreenState extends State<RideListScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawerEnableOpenDragGesture: false,
      key: _key,
      endDrawer: FilterScreen(),
      body: SafeArea( 
        child: Consumer<FilterProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                CustomAppBar(title: 'Find a Ride'.tr()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      _key.currentState!.openEndDrawer();
                      //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FilterScreen()));

                    },
                    child: Row(
                      mainAxisAlignment: isEnglish(context)?MainAxisAlignment.end:MainAxisAlignment.start,
                      children: [
                        Image.asset('assets/images/edit.png',height: 30,),
                        const SizedBox(width: 10,),
                        Text('Filter by'.tr()),
                      ],
                    ),
                  ),
                ),
                if(!provider.allRides)
                  Expanded(
                    child: FutureBuilder<List<RideModel>>(
                        future: FirebaseApi.getRides(context),
                        builder: (context, AsyncSnapshot<List<RideModel>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              child: Text("-",style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300)),
                            );
                          }
                          else {
                            if (snapshot.hasError) {
                              print("error ${snapshot.error}");
                              return const Center(
                                child: Text("Something went wrong"),
                              );
                            }

                            if (snapshot.data!.isEmpty) {
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


                            else {


                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, int index){
                                  return rideCard(snapshot.data![index]);
                                },
                              );
                            }
                          }
                        }
                    ),
                  )
                else
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('rides').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              children: [
                                const Text("Something Went Wrong",style: TextStyle(color: Colors.black))

                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data!.size==0){
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

                        return ListView(
                          shrinkWrap: true,

                          children: snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            RideModel model=RideModel.fromMap(data,document.reference.id);
                            return rideCard(model);
                          }).toList(),
                        );
                      },
                    ),
                  )

              ],
            );
          },
        ),
      ),
    );
  }
  Widget rideCard(RideModel model){
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
                              FutureBuilder<UserModel>(
                                  future: FirebaseApi.getUserData(model.userId),
                                  builder: (context, AsyncSnapshot<UserModel> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        child: Text("-",style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300)),
                                      );
                                    }
                                    else {
                                      if (snapshot.hasError) {
                                        print("error ${snapshot.error}");
                                        return const Center(
                                          child: Text("Something went wrong"),
                                        );
                                      }


                                      else {


                                        return InkWell(
                                          onTap: (){

                                          },
                                          child: Row(
                                            children: [
                                              ProfilePicture(url:snapshot.data!.profilePic,height: 30,width: 30,),
                                              SizedBox(width: 10,),
                                              Text('${snapshot.data!.firstName} ${snapshot.data!.lastName}',style: TextStyle(color: Colors.white),)
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  }
                              ),
                              SizedBox(height: 5,),
                              Text('${model.departureNeighbour.tr()}, ${model.departureCity.tr()} ${'to'.tr()} ${model.arrivalNeighbour.tr()}, ${model.arrivalCity.tr()}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),),
                              SizedBox(height: 5,),
                              Text('${model.date} ${model.time}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w300,fontSize: 14),),


                            ],
                          ),
                        ),
                        if(model.userId!=FirebaseAuth.instance.currentUser!.uid)
                          InkWell(
                          onTap: ()async{
                            if(model.userId!=FirebaseAuth.instance.currentUser!.uid){
                              bool exists=false;
                              await FirebaseFirestore.instance.collection('chat_head').get().then((QuerySnapshot querySnapshot) {
                                querySnapshot.docs.forEach((doc) {
                                  if(checkIfChatExists(doc.reference.id,FirebaseAuth.instance.currentUser!.uid,model.userId)){
                                    exists=true;
                                    print('chat exists ${doc.reference.id}');
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ChatScreen(doc.reference.id)));
                                  }
                                });
                              });
                              if(!exists){
                                print('create new chat ${model.userId}');
                                await FirebaseFirestore.instance.collection('chat_head').doc("${FirebaseAuth.instance.currentUser!.uid}_${model.userId}").set({
                                  "user1":FirebaseAuth.instance.currentUser!.uid,
                                  "user2":model.userId,
                                  "timestamp":DateTime.now().millisecondsSinceEpoch,
                                });
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ChatScreen("${FirebaseAuth.instance.currentUser!.uid}_${model.userId}")));

                              }
                            }

                            },

                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.chat_outlined,color: primaryColor,),
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
