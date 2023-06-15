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
import 'package:tawseleh/screens/auth/register.dart';
import 'package:tawseleh/screens/homepage.dart';
import 'package:tawseleh/utils/constants.dart';
import 'package:tawseleh/widgets/custom_appbar.dart';

import '../../api/auth_api.dart';
import '../../model/user_model.dart';
import '../../provider/user_provider.dart';

class NewPasswordScreen extends StatefulWidget {
  String phoneNumber;

  NewPasswordScreen(this.phoneNumber);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();

  String phone='';
  final _formKey = GlobalKey<FormState>();
  var _passwordController=TextEditingController();
  var _confirmPasswordController=TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  CustomAppBar(title: 'Forget Password'.tr()),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      //obscureText: _isObscure,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        if(!validateStructure(value)){
                          return 'PasswordCriteria'.tr();
                        }
                        return null;
                      },
                      controller: _passwordController,
                      decoration: InputDecoration(
                        /*suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),*/
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
                        hintText: 'New Password'.tr(),
                        // If  you are using latest version of flutter then lable text and hint text shown like this
                        // if you r using flutter less then 1.20.* then maybe this is not working properly
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      //obscureText: _isObscure,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        if(!validateStructure(value)){
                          return 'PasswordCriteria'.tr();
                        }
                        return null;
                      },
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        /*suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),*/
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
                        hintText: 'Retype the Password'.tr(),
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

                      if(_formKey.currentState!.validate()){
                        final ProgressDialog pr = ProgressDialog(context: context);
                        pr.show(max: 100, msg: 'Please Wait'.tr());

                        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                          'password':_passwordController.text,
                        }).then((value)async{
                          pr.close();
                          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((DocumentSnapshot documentSnapshot) async{
                            if (documentSnapshot.exists) {
                              print("user exists");
                              Map<String, dynamic> data = documentSnapshot.data()! as Map<String, dynamic>;
                              UserModel user=UserModel.fromMap(data,documentSnapshot.reference.id);
                              print("user ${user.userId} ${user.status}");
                              final provider = Provider.of<UserDataProvider>(context, listen: false);
                              provider.setUserData(user);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Homepage()));
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

                    },
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Text('Change Password'.tr(),style: TextStyle(fontSize:16,color:Colors.white),),
                    ),
                  ),
                ),
              ),

            ],
          ),
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
