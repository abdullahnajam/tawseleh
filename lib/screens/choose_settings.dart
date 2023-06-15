import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:tawseleh/screens/my_rides.dart';
import 'package:tawseleh/screens/profile_screen.dart';

import '../cities.dart';
import '../provider/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_appbar.dart';
import 'auth/auth_info_screen.dart';

class ChooseSettings extends StatefulWidget {
  const ChooseSettings({Key? key}) : super(key: key);

  @override
  State<ChooseSettings> createState() => _ChooseSettingsState();
}

class _ChooseSettingsState extends State<ChooseSettings> {
  final _changeController=TextEditingController();
  List<String> genders = <String>['Male', 'Female'];
  String selectedLanguage=languages.first;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
     setState(() {
       print('lang ${context.locale.languageCode}');
       if(context.locale.languageCode=='ar'){
         selectedLanguage=languages.last;
       }

     });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Your Profile'.tr(),

            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen()));

                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Image.asset('assets/images/user.png',height: 25,),
                                  SizedBox(width: 10,),
                                  Text('Personal Information'.tr(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                                ],
                              ),
                              SizedBox(height: 15,),
                              Text(
                                'Photo, Name, Phone Number, Gender'.tr(),
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){

                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(

                                children: [
                                  Image.asset('assets/images/language.png',height: 25, width: 25,),
                                  SizedBox(width: 10,),
                                  Text('Language'.tr(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                                ],
                              ),
                              DropdownButton<String>(
                                value: selectedLanguage,
                                icon: const Icon(Icons.arrow_drop_down,color: primaryColor,),
                                elevation: 16,
                                style: const TextStyle(color: primaryColor,fontSize: 13,fontWeight: FontWeight.w500),
                                underline: Container(

                                ),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    selectedLanguage = value!;
                                    if(selectedLanguage=='English'){
                                      context.setLocale(const Locale('en'));
                                    }
                                    else{
                                      context.setLocale(const Locale('ar'));
                                    }
                                  });

                                },
                                items: languages.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        //storeNeighbourhoods();
                        //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MyRideScreen()));
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MyRideScreen()));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Image.asset('assets/images/car.png',height: 25,),
                                  SizedBox(width: 10,),
                                  Text('Rides Created'.tr(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                                ],
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Lottie.asset('assets/json/car.json'),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
  Future uploadImageToFirebase(BuildContext context,File image) async {
    String photoUrl="";
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: 'Please Wait'.tr(),barrierDismissible: false);
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then((value)async {
      photoUrl=value;
      pr.close();
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
        "profilePic":photoUrl,
      }).then((val) {
        final provider = Provider.of<UserDataProvider>(context, listen: false);

        provider.setImage(photoUrl);
        //Navigator.pop(context);
        //Navigator.pop(context);
      });
    }).onError((error, stackTrace){
      pr.close();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: error.toString(),
      );
    });
  }

  _chooseGallery(BuildContext context) async{
    await ImagePicker().pickImage(source: ImageSource.gallery).then((value){
      if(value!=null){
        uploadImageToFirebase(context,File(value.path)).whenComplete(() => Navigator.pop(context));
      }

    });

  }

  _choosecamera(BuildContext context) async{
    await ImagePicker().pickImage(source: ImageSource.camera).then((value){
      if(value!=null){
        uploadImageToFirebase(context,File(value.path)).whenComplete(() => Navigator.pop(context));
      }

    });
  }

  logoModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.cloud_upload),
                    title: Text('Upload Picture'.tr()),
                    onTap: () {
                      if(kIsWeb){

                      }
                      else{
                        _chooseGallery(context);
                      }

                    }),
                if(!kIsWeb)
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: Text('Take a photo'.tr()),
                    onTap: () => {
                      _choosecamera(context)
                    },
                  ),
              ],
            ),
          );
        });
  }
}
