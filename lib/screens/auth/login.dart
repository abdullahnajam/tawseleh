import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:tawseleh/api/auth_api.dart';
import 'package:tawseleh/screens/auth/forgot_password_screen.dart';
import 'package:tawseleh/screens/auth/register.dart';
import 'package:tawseleh/widgets/custom_appbar.dart';

import '../../provider/user_provider.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  var _passwordController=TextEditingController();





  String phone='';

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final provider = Provider.of<UserDataProvider>(context, listen: false);


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'Tawseleh'.tr()),
            Expanded(
              flex: 8,
              child: Form(
                key: _formKey,
                child: Container(
                  //decoration: BoxDecoration(color: colorBackground),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30,),
                        Center(
                          child: Text('Login'.tr(), style: TextStyle(
                            //color: colorBlack,
                              fontSize: 26,
                              fontWeight: FontWeight.w600
                          ),),
                        ),
                        const SizedBox(height: 10,),

                        const SizedBox(height: 20,),
                        InternationalPhoneNumberInput(
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
                        const SizedBox(height: 10,),
                        TextFormField(
                          obscureText: _isObscure,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          controller: _passwordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
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
                            hintText: 'Password'.tr(),
                            // If  you are using latest version of flutter then lable text and hint text shown like this
                            // if you r using flutter less then 1.20.* then maybe this is not working properly
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                        const SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ForgotPasswordScreen()));
                          },
                          child: Text('Forget Password'.tr(), style: TextStyle(
                              color: secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600
                          ),),
                        ),
                        const SizedBox(height: 40,),
                        Center(
                          child: InkWell(
                            onTap: ()async{


                              if(_formKey.currentState!.validate()){
                                final ProgressDialog pr = ProgressDialog(context: context);
                                pr.show(max: 100, msg: 'Please Wait'.tr(),barrierDismissible: true);
                                await AuthenticationApi.loginWithEmailPassword(phone, _passwordController.text).then((value){
                                  pr.close();
                                  if(value){
                                    AuthenticationApi authApi=AuthenticationApi();
                                    authApi.verifyPhoneNumber(phone, context, 1);
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

                              }
                            },
                            child: Container(
                              height: 40,
                              width: width,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: Text('Login'.tr(),style: TextStyle(fontSize:16,color:Colors.white),),
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),

                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Center(
                        child:Text('Dont have an account yet?'.tr(), style: TextStyle(fontSize: 14),)
                    ),
                  ),
                  Center(
                      child:InkWell(
                          onTap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const RegisterScreen()));
                          },
                          child: Text('Sign Up'.tr(), style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold),)
                      )
                  ),
                ],
              ),
            )
          ],
        ),

      ),
    );
  }
}
