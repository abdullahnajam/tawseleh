import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tawseleh/utils/constants.dart';

class CustomBackButton extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pop(context);
      },
      child: SizedBox(
        height: 50,
        width: 55,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
         child:Center(
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Padding(
                 padding: const EdgeInsets.only(left: 15,right: 10,top: 10,bottom: 10),
                 child: Icon(isEnglish(context)?Icons.arrow_back_ios:Icons.arrow_forward_ios,color: Colors.black,size: 20,),
               ),
             ],
           ),
         ),
        ),
      ),
    );
  }
}
