import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:tawseleh/screens/auth/auth_info_screen.dart';
import 'package:tawseleh/screens/homepage.dart';
import 'package:tawseleh/utils/constants.dart';
import 'package:tawseleh/widgets/custom_appbar.dart';

import '../../model/user_model.dart';
import '../../provider/user_provider.dart';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  String id;
  int intent;
  String phone;


  OtpVerificationScreen(this.id, this.intent,this.phone);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> _showDeleteAccountDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Your account is deleted'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthInfo()), (Route<dynamic> route) => false);

              },
            ),
          ],
        );
      },
    );
  }

  Future<void> register(PhoneAuthCredential credential)async{
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: 'Please Wait'.tr());
       if (FirebaseAuth.instance.currentUser == null) {
         await FirebaseAuth.instance.signInWithCredential(credential).then((value)async{
           String? token="";
           FirebaseMessaging _fcm=FirebaseMessaging.instance;
           token=await _fcm.getToken();
           final provider = Provider.of<UserDataProvider>(context, listen: false);
           Map<String,dynamic> data={
             'phone':provider.userData!.phone,
             'password':provider.userData!.password,
             'status':'Approved',
             'token':token,
             'gender':provider.userData!.gender,
             'firstName':provider.userData!.firstName,
             'lastName':provider.userData!.lastName,
             'profilePic':'',
           };
           UserModel model=UserModel.fromMap(
               data,
               FirebaseAuth.instance.currentUser!.uid
           );
           provider.setUserData(model);
           await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set(data);
           pr.close();
           Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Homepage()), (Route<dynamic> route) => false);

           //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const RegisterScreen()));

         }).onError((error, stackTrace) {
           pr.close();
           CoolAlert.show(
             context: context,
             type: CoolAlertType.error,
             text: error.toString(),
           );
         });
       }
       else{
         String? token="";
         FirebaseMessaging _fcm=FirebaseMessaging.instance;
         token=await _fcm.getToken();
         final provider = Provider.of<UserDataProvider>(context, listen: false);
         Map<String,dynamic> data={
           'phone':provider.userData!.phone,
           'password':provider.userData!.password,
           'status':'Approved',
           'token':token,
           'gender':provider.userData!.gender,
           'firstName':provider.userData!.firstName,
           'lastName':provider.userData!.lastName,
           'profilePic':'',
         };
         UserModel model=UserModel.fromMap(
             data,
             FirebaseAuth.instance.currentUser!.uid
         );
         provider.setUserData(model);
         await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set(data);
         pr.close();
         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Homepage()), (Route<dynamic> route) => false);
       }

  }

  Future<void> login(PhoneAuthCredential credential)async{
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: 'Please Wait'.tr());
    
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInWithCredential(credential).then((value)async{
        pr.close();
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((DocumentSnapshot documentSnapshot) async{
          if (documentSnapshot.exists) {
            print("user exists");
            Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
            UserModel user=UserModel.fromMap(data,documentSnapshot.reference.id);
            print("user ${user.userId} ${user.status}");
            String? token="";

            FirebaseMessaging _fcm=FirebaseMessaging.instance;
            token=await _fcm.getToken();
            print('fcm token else $token');
            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
              'token':token,
            });
            final provider = Provider.of<UserDataProvider>(context, listen: false);
            provider.setUserData(user);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Homepage()));
          }
          else{
            CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              text: 'No User In Database',
            );
          }

        });

      }).onError((error, stackTrace) {
        pr.close();
        CoolAlert.show(
          context: context,
          title: 'Login Error',
          type: CoolAlertType.error,
          text: error.toString(),
        );
      });
    }
    else{
      pr.close();
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((DocumentSnapshot documentSnapshot) async{
        if (documentSnapshot.exists) {
          print("user exists");
          Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
          UserModel user=UserModel.fromMap(data,documentSnapshot.reference.id);
          print("user ${user.userId} ${user.status}");
          String? token="";
          FirebaseMessaging _fcm=FirebaseMessaging.instance;
          token=await _fcm.getToken();
          print('fcm token else $token');
          FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
            'token':token,
          });
          final provider = Provider.of<UserDataProvider>(context, listen: false);
          provider.setUserData(user);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Homepage()));
        }




      });
    }


  }

  Future<void> forgotPassword(PhoneAuthCredential credential)async{
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: 'Please Wait'.tr());
    await FirebaseAuth.instance.signInWithCredential(credential).then((value)async{
      pr.close();
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((DocumentSnapshot documentSnapshot) async{
        if (documentSnapshot.exists) {
          print("user exists");
          Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
          UserModel user=UserModel.fromMap(data,documentSnapshot.reference.id);
          print("user ${user.userId} ${user.status}");
          final provider = Provider.of<UserDataProvider>(context, listen: false);
          provider.setUserData(user);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => NewPasswordScreen(widget.phone)));
        }

      });

    }).onError((error, stackTrace) {
      pr.close();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: error.toString(),
      );
    });

  }

  Future<void> deleteAccount(PhoneAuthCredential credential)async{
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: 'Please Wait'.tr());
    await FirebaseAuth.instance.signInWithCredential(credential).then((value)async{
      String userId=FirebaseAuth.instance.currentUser!.uid;
      FirebaseAuth.instance.currentUser!.delete().then((value){
        pr.close();
        FirebaseFirestore.instance.collection('users').doc(userId).delete();
        _showDeleteAccountDialog();
      }).onError((error, stackTrace) {
        pr.close();
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: error.toString(),
        );
      });

    }).onError((error, stackTrace) {
      pr.close();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: error.toString(),
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'confirm OTP'.tr()),
            SizedBox(height: MediaQuery.of(context).size.height*0.06,),
            Image.asset('assets/images/otp.png',height: MediaQuery.of(context).size.height*0.2,),
            SizedBox(height: MediaQuery.of(context).size.height*0.06,),
            Text('You will receive a code to confirm your mobile number shortly'.tr(),textAlign: TextAlign.center,),
            SizedBox(height: MediaQuery.of(context).size.height*0.05,),
            Localizations.override(
              context: context,
              locale: Locale('en'),
              child: OtpTextField(
                numberOfFields: 6,

                borderColor: primaryColor,
                //set to true to show as box or false to show as dash
                showFieldAsBox: true,
                //runs when a code is typed in
                onCodeChanged: (String code) {
                  //handle validation or checks here
                },
                //runs when every textfield is filled
                onSubmit: (String verificationCode)async{


                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.id,
                    smsCode: verificationCode,
                  );

                  if(widget.intent==0){
                    register(credential);
                  }
                  else if(widget.intent==1){
                    login(credential);
                  }
                  else if(widget.intent==2){
                    forgotPassword(credential);
                  }
                  else if(widget.intent==3){
                    deleteAccount(credential);
                  }


                }, // end onSubmit
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget otpTextField(int index) {
    return SizedBox(
      width: 60.0,
      child: TextFormField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: '*',
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
