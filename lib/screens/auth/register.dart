import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:tawseleh/api/auth_api.dart';
import 'package:tawseleh/model/user_model.dart';
import 'package:tawseleh/screens/auth/login.dart';
import 'package:tawseleh/screens/auth/otp_screen.dart';

import '../../provider/user_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_appbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

bool validateStructure(String value){
  String  pattern = r'^(?=.*?[a-z])(?=.*?[0-9])';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(value);
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isObscure = true;

  var _firstController=TextEditingController();
  var _lastController=TextEditingController();
  var _passwordController=TextEditingController();

  String selectedGender='Male'.tr();
  String gender='Male';
  List<String> genders = <String>['Male'.tr(), 'Female'.tr()];
  String phone='';

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final provider = Provider.of<UserDataProvider>(context, listen: false);
   

    return Scaffold(

      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'Tawseleh'.tr()),
            // Main Container of Screen
            Expanded(
              child: Container(
                //decoration: BoxDecoration(color: colorBackground),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        const SizedBox(height: 30,),
                        Center(
                          child: Text('Lets create an account!'.tr(), style: TextStyle(
                            //color: colorBlack,
                              fontSize: 26,
                              fontWeight: FontWeight.w600
                          ),),
                        ),
                        const SizedBox(height: 40,),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text'.tr();
                                  }
                                  return null;
                                },
                                controller: _firstController,
                                decoration: InputDecoration(
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
                                  hintText: 'First Name'.tr(),
                                  // If  you are using latest version of flutter then lable text and hint text shown like this
                                  // if you r using flutter less then 1.20.* then maybe this is not working properly
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text'.tr();
                                  }
                                  return null;
                                },
                                controller: _lastController,
                                decoration: InputDecoration(
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
                                  hintText: 'Last Name'.tr(),
                                  // If  you are using latest version of flutter then lable text and hint text shown like this
                                  // if you r using flutter less then 1.20.* then maybe this is not working properly
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                              ),
                            )
                          ],
                        ),
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
                        const SizedBox(height: 20,),
                        TextFormField(
                          obscureText: _isObscure,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text'.tr();
                            }
                            if(!validateStructure(value)){
                              return 'PasswordCriteria'.tr();
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
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(7)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10,0,15,0),
                            child: DropdownButton<String>(
                              value: selectedGender,
                              icon: const Icon(Icons.arrow_drop_down,color: Colors.black),
                              elevation: 16,
                              isExpanded: true,
                              underline: Container(),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedGender = value!;
                                  if(selectedGender==genders.first){
                                    gender='Male';
                                  }
                                  else{
                                    gender='Female';
                                  }
                                });
                              },
                              items: genders.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,

                                  child: Text(value,style: const TextStyle(color:  Colors.black, ),),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50,),
                        Center(
                          child: InkWell(
                            onTap: ()async{


                              if(_formKey.currentState!.validate()){
                                final ProgressDialog pr = ProgressDialog(context: context);
                                pr.show(max: 100, msg: 'Please Wait'.tr(),barrierDismissible: true);
                                final provider = Provider.of<UserDataProvider>(context, listen: false);
                                UserModel model=UserModel.fromMap(
                                  {
                                     'phone':phone,
                                     'password':_passwordController.text,
                                     'status':'Approved',
                                     'gender':gender,
                                     'token':'',
                                     'firstName':_firstController.text.trim(),
                                     'lastName':_lastController.text.trim(),
                                     'profilePic':'',
                                  },
                                  ''
                                );
                                provider.setUserData(model);
                                AuthenticationApi authApi=AuthenticationApi();
                                bool exists=false;
                                await FirebaseFirestore.instance.collection('users').where("phone",isEqualTo: phone).get().then((QuerySnapshot querySnapshot) {
                                  querySnapshot.docs.forEach((doc) {
                                    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                                    exists=true;
                                  });
                                });
                                pr.close();
                                if(exists){
                                  CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.error,
                                    text: 'User already registered'.tr(),
                                  );
                                }
                                else{
                                  authApi.verifyPhoneNumber(phone, context, 0);

                                }

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
                              child: Text('Sign Up'.tr(),style: TextStyle(fontSize:16,color: Colors.white),),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30,),
                        Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Center(
                              child:Text('Already have an account?'.tr(), style: TextStyle( fontSize: 14),)
                          ),
                        ),
                        Center(
                            child:InkWell(
                                onTap: (){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>LoginScreen()));
                                },
                                child: Text('Login'.tr(), style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold),)
                            )
                        ),

                      ],
                    ),
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
