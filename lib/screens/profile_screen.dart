import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:tawseleh/api/auth_api.dart';
import 'package:tawseleh/screens/my_rides.dart';

import '../provider/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_appbar.dart';
import 'auth/auth_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _changeController=TextEditingController();
  List<String> genders = <String>['Male', 'Female'];
  String selectedLanguage=languages.first;

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
              child: Consumer<UserDataProvider>(
                builder: (context, provider, child) {
                  return ListView(
                    children: [
                      ListTile(
                          onTap: (){
                            logoModalBottomSheet(context);
                          },
                          title: Text('Account Photo'.tr(),style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),),
                          trailing: provider.userData!.profilePic==''?
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade400,
                          )
                              :
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: NetworkImage(provider.userData!.profilePic),
                                    fit: BoxFit.cover
                                )
                            ),
                          )

                      ),
                      ListTile(

                        title: Text('Phone Number'.tr(),style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),),
                        subtitle: Text(provider.userData!.phone,style: const TextStyle(fontWeight: FontWeight.w300,color: Colors.grey),),
                        trailing: InkWell(
                          onTap: ()async{
                            FirebaseAuth.instance.signOut().then((value){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const AuthInfo()));

                            }).onError((error, stackTrace){
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,
                                text: error.toString(),
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10,5,10,5),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(30)
                            ),
                            child: Text('Sign Out'.tr(),style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300,),),
                          ),
                        ),

                      ),
                      ListTile(
                        onTap: (){
                          _changeController.text="";
                          showDialog<void>(
                            context: context,
                            barrierDismissible: true, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Password'.tr()),
                                content:  TextFormField(
                                  controller: _changeController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,

                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child:  Text('LATER'.tr(),style: TextStyle(color: primaryColor),),
                                    onPressed: () {
                                      Navigator.pop(context);

                                      //Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child:  Text('CHANGE'.tr(),style: TextStyle(color: primaryColor)),
                                    onPressed: () async{
                                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                                        'password':_changeController.text,

                                      }).then((val){
                                        final provider = Provider.of<UserDataProvider>(context, listen: false);
                                        provider.setPassword(_changeController.text);
                                        Navigator.pop(context);

                                        //Navigator.pop(context);
                                      }).onError((error, stackTrace){
                                        CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.error,
                                          text: error.toString(),
                                        );
                                      });

                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        trailing: Icon(Icons.edit),
                        title: Text('Password'.tr(),style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),),
                        subtitle: Text(provider.userData!.password.replaceRange(0, provider.userData!.password.length, '*' * provider.userData!.password.length),style: const TextStyle(fontWeight: FontWeight.w300,color: Colors.grey),),

                      ),
                      ListTile(
                        title: Text('Gender'.tr(),style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),),
                        subtitle: Text('Set your gender'.tr(),style: TextStyle(fontWeight: FontWeight.w300,color: Colors.grey),),
                        trailing:  DropdownButton<String>(
                          value: provider.userData!.gender,
                          icon: const Icon(Icons.arrow_drop_down,color: primaryColor,),
                          elevation: 16,
                          style: const TextStyle(color: primaryColor,fontSize: 13,fontWeight: FontWeight.w500),
                          underline: Container(

                          ),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              provider.userData!.gender = value!;
                              if(provider.userData!.gender==genders.first){
                                provider.userData!.gender='Male';
                              }
                              else{
                                provider.userData!.gender='Female';
                              }
                            });
                            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                              "gender":provider.userData!.gender,
                            });

                            provider.setGender(value!);
                          },
                          items: genders.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.tr()),
                            );
                          }).toList(),
                        ),
                      ),
                      ListTile(
                        onTap: (){
                          _changeController.text="";
                          showDialog<void>(
                            context: context,
                            barrierDismissible: true, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('First Name'.tr()),
                                content:  TextFormField(
                                  controller: _changeController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,

                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child:  Text('LATER'.tr(),style: TextStyle(color: primaryColor),),
                                    onPressed: () {
                                      Navigator.pop(context);

                                      //Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child:  Text('CHANGE'.tr(),style: TextStyle(color: primaryColor)),
                                    onPressed: () async{
                                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                                        'firstName':_changeController.text,

                                      }).then((val){
                                        final provider = Provider.of<UserDataProvider>(context, listen: false);
                                        provider.setFirstName(_changeController.text);
                                        Navigator.pop(context);

                                        //Navigator.pop(context);
                                      }).onError((error, stackTrace){
                                        CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.error,
                                          text: error.toString(),
                                        );
                                      });

                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        trailing: Icon(Icons.edit),
                        title: Text('First Name'.tr(),style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),),
                        subtitle: Text(provider.userData!.firstName,style: const TextStyle(fontWeight: FontWeight.w300,color: Colors.grey),),

                      ),
                      ListTile(
                        onTap: (){
                          _changeController.text="";
                          showDialog<void>(
                            context: context,
                            barrierDismissible: true, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Last Name'.tr()),
                                content:  TextFormField(
                                  controller: _changeController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: true,

                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child:  Text('LATER'.tr(),style: TextStyle(color: primaryColor),),
                                    onPressed: () {
                                      Navigator.pop(context);

                                      //Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child:  Text('CHANGE'.tr(),style: TextStyle(color: primaryColor)),
                                    onPressed: () async{
                                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                                        'lastName':_changeController.text,

                                      }).then((val){
                                        final provider = Provider.of<UserDataProvider>(context, listen: false);
                                        provider.setLastName(_changeController.text);
                                        Navigator.pop(context);

                                        //Navigator.pop(context);
                                      }).onError((error, stackTrace){
                                        CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.error,
                                          text: error.toString(),
                                        );
                                      });

                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        trailing: Icon(Icons.edit),
                        title: Text('Last Name'.tr(),style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),),
                        subtitle: Text(provider.userData!.lastName,style: const TextStyle(fontWeight: FontWeight.w300,color: Colors.grey),),

                      ),
                      ListTile(
                        onTap: (){
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.confirm,
                            title: 'Delete Account'.tr(),
                            text: 'Are you sure you want to delete your account? All your data will be lost'.tr(),
                            onConfirmBtnTap: (){
                              AuthenticationApi authApi=AuthenticationApi();
                              authApi.verifyPhoneNumber(provider.userData!.phone, context, 3);

                            }
                          );
                        },
                        trailing: Icon(Icons.delete),
                        title: Text('Delete Account'.tr(),style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),),


                      ),












                    ],
                  );
                },
              ),
            )
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
