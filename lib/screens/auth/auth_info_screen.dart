import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tawseleh/screens/auth/register.dart';
import 'package:tawseleh/utils/constants.dart';

import 'login.dart';

class AuthInfo extends StatefulWidget {
  const AuthInfo({Key? key}) : super(key: key);

  @override
  State<AuthInfo> createState() => _AuthInfoState();
}

class _AuthInfoState extends State<AuthInfo> {

  String selectedLanguage=languages.first;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {
        print('lang ${context.locale.languageCode}');
        if(!isEnglish(context)){
          selectedLanguage=languages.last;
        }

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  )
                ),
                height: MediaQuery.of(context).size.height*0.35,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.topRight,
                child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5,right: 10),
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        icon: const Icon(Icons.arrow_drop_down,color: Colors.black),
                        elevation: 16,

                        underline: Container(),
                        onChanged: (String? value) {
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

                            child: Text(value,style: const TextStyle(color:  Colors.black, ),),
                          );
                        }).toList(),
                      ),
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.2),
                child: Center(
                  child: Image.asset('assets/images/logo.png',height: MediaQuery.of(context).size.height*0.25,),
                ),
              )
              
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Center(child: Text('Welcome to Tawseleh'.tr(),textAlign: TextAlign.center,style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w500))),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(child: Text('Take Advantage of Our Services for FREE'.tr(),textAlign: TextAlign.center,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w400))),
              ),
            ],
          ),
          Column(

            children: [

              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));

                        },
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: primaryColor)
                          ),
                          child: Text('Login'.tr(),style: TextStyle(fontSize: 16),),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RegisterScreen()));

                        },
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.all(5),
                          alignment: Alignment.center,
                          child:  Text('Sign Up'.tr(),style: TextStyle(fontSize: 16)),
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: primaryColor)
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30,)
            ],
          )
        ],
      ),
    );
  }
}
