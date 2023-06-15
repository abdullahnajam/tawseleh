import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:tawseleh/screens/auth/otp_screen.dart';
import 'package:tawseleh/screens/homepage.dart';
import 'package:tawseleh/utils/constants.dart';
import 'package:tawseleh/widgets/custom_appbar.dart';

import '../../api/auth_api.dart';
import '../../model/user_model.dart';
import '../../provider/user_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();

  String phone='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                CustomAppBar(title: 'Forget Password'.tr()),
                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (value){
                      phone=value.phoneNumber!;
                      print(phone);
                    },

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text'.tr();
                      }
                      return null;
                    },
                    countries: ["JO",'PK'],
                    //controller: _phoneController,
                    inputDecoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 0.5
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 0.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Phone Number'.tr(),
                      // If  you are using latest version of flutter then lable text and hint text shown like this
                      // if you r using flutter less then 1.20.* then maybe this is not working properly
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20,20,20,40),
                child: InkWell(
                  onTap: ()async{


                    final ProgressDialog pr = ProgressDialog(context: context);
                    pr.show(max: 100, msg: 'Please Wait'.tr(),barrierDismissible: true);
                    await AuthenticationApi.checkIfUserExists(phone).then((value){
                      pr.close();
                      if(value){
                        AuthenticationApi authApi=AuthenticationApi();
                        authApi.verifyPhoneNumber(phone, context, 2);
                      }
                      else{
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          text: 'Phone number and password do not match'.tr(),
                        );
                      }
                    }).onError((error, stackTrace) {
                      pr.close();
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.error,
                        text: error.toString(),
                      );
                    });
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text('Next'.tr(),style: TextStyle(fontSize:16,color:Colors.white),),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

}
